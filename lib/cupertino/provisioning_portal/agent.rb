require 'mechanize'
require 'security'

module Cupertino
  module ProvisioningPortal
    class Agent < ::Mechanize
      attr_accessor :username, :password, :team

      def initialize
        super
        self.user_agent_alias = 'Mac Safari'

        pw = Security::InternetPassword.find(:server => Cupertino::HOSTNAME)
        @username, @password = pw.attributes['acct'], pw.password if pw
      end

      def get(uri, parameters = [], referer = nil, headers = {})
        uri = ::File.join("https://#{Cupertino::HOSTNAME}", uri) unless /^https?/ === uri

        3.times do
          super(uri, parameters, referer, headers)

          return page unless page.respond_to?(:title)

          case page.title
          when %r{Sign in with your Apple ID}
            login! and redo
          when %r{Select Your Team}
            select_team! and redo
          else
            return page
          end
        end

        raise UnsuccessfulAuthenticationError
      end

      def list_certificates(type = :development)
        url = case type
              when :development
                "https://developer.apple.com/ios/manage/certificates/team/index.action"
              when :distribution
                "https://developer.apple.com/ios/manage/certificates/team/distribute.action"
              else
                raise ArgumentError, "Certificate type must be :development or :distribution"
              end

        get(url)

        certificates = []
        page.parser.xpath('//div[@class="nt_multi"]/table/tbody/tr').each do |row|
          certificate = Certificate.new
          certificate.name = row.at_xpath('td[@class="name"]//p/text()').to_s.strip rescue nil
          certificate.type = type
          certificate.provisioning_profiles = row.at_xpath('td[@class="profiles"]/text()').to_s.strip.split(/\n+/) rescue []
          certificate.expiration_date = row.at_xpath('td[@class="date"]/text()').to_s.strip rescue nil
          certificate.status = row.at_xpath('td[@class="status"]/text()').to_s.strip rescue nil
          certificates << certificate
        end
        certificates
      end

      def download_certificate(certificate)
        list_certificates(certificate.type)

        page.parser.xpath('//div[@class="nt_multi"]/table/tbody/tr').each do |row|
          name = row.at_xpath('td[@class="name"]//p/text()').to_s.strip rescue nil

          if name == certificate.name
            download_url = row.at_xpath('td[@class="last"]/a')['href'].to_s.strip rescue nil

            self.pluggable_parser.default = Mechanize::Download
            download = get(download_url)
            download.save
            return download.filename
          end
        end

        return nil
      end

      def list_devices
        get("https://developer.apple.com/ios/manage/devices/index.action")

        devices = []
        page.parser.xpath('//fieldset[@id="fs-0"]/table/tbody/tr').each do |row|
          device = Device.new
          device.name = row.at_xpath('td[@class="name"]/span/text()').to_s.strip rescue nil
          device.udid = row.at_xpath('td[@class="id"]/text()').to_s.strip rescue nil
          devices << device
        end

        if message = page.parser.at_xpath('//p[@class="devicesannounce"]/strong/text()').to_s.strip rescue nil
          number_of_devices_available = message.scan(/\d{1,3}/).first.to_i
          number_of_devices_available.times do
            devices << nil
          end
        end

        devices
      end

      def add_devices(*devices)
        return if devices.empty?

        get("https://developer.apple.com/ios/manage/devices/upload.action")

        begin
          file = Tempfile.new(['devices', '.txt'])
          file.write("deviceIdentifier\tdeviceName")
          devices.each do |device|
            file.write("\n#{device.udid}\t#{device.name}")
          end
          file.rewind

          if form = page.form_with(:name => 'saveupload')
            upload = form.file_uploads.first
            upload.file_name = file.path
            form.submit
          end
        ensure
          file.close!
        end
      end

      def list_profiles(type = :development)
        url = case type
              when :development
                "https://developer.apple.com/ios/manage/provisioningprofiles/index.action"
              when :distribution
                  "https://developer.apple.com/ios/manage/provisioningprofiles/viewDistributionProfiles.action"
              else
                raise ArgumentError, "Provisioning profile type must be :development or :distribution"
              end

        get(url)

        profiles = []
        page.parser.xpath('//fieldset[@id="fs-0"]/table/tbody/tr').each do |row|
          profile = ProvisioningProfile.new
          profile.name = row.at_xpath('td[@class="profile"]//text()').to_s.strip rescue nil
          profile.type = type
          profile.app_id = row.at_xpath('td[@class="appid"]/text()').to_s.strip rescue nil
          profile.status = row.at_xpath('td[@class="statusXcode"]/text()').to_s.strip rescue nil
          profiles << profile
        end
        profiles
      end

      def download_profile(profile)
        list_profiles(profile.type)

        page.parser.xpath('//fieldset[@id="fs-0"]/table/tbody/tr').each do |row|
          name = row.at_xpath('td[@class="profile"]//span/text()').to_s.strip rescue nil

          if name == profile.name
            download_url = row.at_xpath('td[@class="action"]/a')['href'].to_s.strip rescue nil

            self.pluggable_parser.default = Mechanize::Download
            download = get(download_url)
            download.save
            return download.filename
          end
        end

        return nil
      end

      def manage_devices_for_profile(profile)
        raise ArgumentError unless block_given?

        list_profiles(profile.type)

        modify_url = nil
        page.parser.xpath('//fieldset[@id="fs-0"]/table/tbody/tr').each do |row|
          break if modify_url

          name = row.at_xpath('td[@class="profile"]//text()').to_s.strip rescue nil

          if name == profile.name
            row.css('td.action a').each do |a|
              if /edit\.action/ === a['href']
                modify_url = a['href']
              end
            end
          end
        end

        if modify_url
          get(modify_url)

          on, off = [], []
          page.parser.css('.checkboxlist.last td').each do |td|
            checkbox = td.at_xpath('input[@type="checkbox"]')

            device = Device.new
            device.name = td.at_xpath('label/text()').to_s.strip rescue nil
            device.udid = checkbox['value'].to_s.strip rescue nil

            if checkbox['checked']
              on << device
            else
              off << device
            end
          end

          devices = yield on, off

          form = page.form_with(:name => 'save')
          form.checkboxes_with(:name => "selectedDevices").each do |checkbox|
            checkbox.check
            if devices.detect{|device| device.udid == checkbox['value']}
              checkbox.check
            else
              checkbox.uncheck
            end
          end

          button = form.button_with(:name => 'submit')
          form.click_button(button)
        end

        return nil
      end

      def list_app_ids
        get("https://developer.apple.com/ios/manage/bundles/index.action")

        app_ids = []
        page.parser.xpath('//div[@class="nt_multi"]/table/tbody/tr').each do |row|
          app_id = AppID.new
          app_id.bundle_seed_id = row.at_xpath('td[@class="name"]/strong/text()').to_s.strip rescue nil
          app_id.description = row.at_xpath('td[@class="name"]/text()').to_s.strip rescue nil

          keys = row.xpath('td[@class="name"]/p/text()').collect(&:to_s).collect(&:strip)
          app_id.development_properties, app_id.distribution_properties = row.xpath('td')[1..2].collect do |td|
            values = td.xpath('p//text()').collect(&:to_s).collect(&:strip).reject{|text| text.empty?}
            keys.zip(values)
            keys.zip(values)
          end

          app_ids << app_id
        end
        app_ids
      end
      
      def list_pass_type_ids
        get("https://developer.apple.com/ios/manage/passtypeids/index.action")
        
        pass_type_ids = []
        page.parser.xpath('//fieldset[@id="fs-0"]/table/tbody/tr').each do |row|
          pass_type_id = PassTypeID.new
          pass_type_id.id = row.at_xpath('td[@class="name"]/strong/text()').to_s.strip rescue nil
          pass_type_id.description = row.at_xpath('td[@class="name"]/text()').to_s.strip rescue nil
          
          pass_type_ids << pass_type_id
        end
        pass_type_ids
      end
      
      def add_pass_type_id(pass_type_id, description)
        get("https://developer.apple.com/ios/manage/passtypeids/add.action")
        
        if form = page.form_with(:name => 'save')
          form['cardName'] = description
          form['cardIdentifier'] = pass_type_id
          
          button = form.button_with(:name => 'submit')
          form.click_button(button)
        end
      end
        
      private

      def login!
        if form = page.form_with(:name => 'appleConnectForm')
          form.theAccountName = self.username
          form.theAccountPW = self.password
          form.submit
        end
      end

      def select_team!
        if form = page.form_with(:name => 'saveTeamSelection')
          team_list = form.field_with(:name => 'memberDisplayId')
          team_option = team_list.option_with(:text => self.team)
          team_option.select

          button = form.button_with(:name => 'action:saveTeamSelection!save')
          form.click_button(button)
        end
      end
    end
  end
end
