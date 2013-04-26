require 'mechanize'
require 'security'
require 'json'

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
            when /Sign in with your Apple ID/
              login! and redo
            when /Select Team/
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
                  "https://developer.apple.com/account/ios/certificate/certificateList.action?type=development"
                when :distribution
                  "https://developer.apple.com/account/ios/certificate/certificateList.action?type=distribution"
                else
                raise ArgumentError, "Certificate type must be :development or :distribution"
              end

        get(url)

        regex = /certificateDataURL = "([^"]*)"/
        certificate_data_url = (page.body.match regex or raise UnexpectedContentError)[1]

        regex = /certificateRequestTypes = "([^"]*)"/
        certificate_request_types = (page.body.match regex or raise UnexpectedContentError)[1]

        regex = /certificateStatuses = "([^"]*)"/
        certificate_statuses = (page.body.match regex or raise UnexpectedContentError)[1]

        certificate_data_url += certificate_request_types + certificate_statuses

        get(certificate_data_url)
        certificate_data = page.content
        parsed_certificate_data = JSON.parse(certificate_data)

        certificates = []
        parsed_certificate_data['certRequests'].each do |row|
          certificate = Certificate.new
          certificate.name = row['name']
          certificate.type = type
          certificate.download_url = 'https://developer.apple.com/account/ios/certificate/certificateContentDownload.action?displayId=' + row['certificateId'] + '&type=' + row['certificateTypeDisplayId']
          certificate.expiration_date = row['expirationDateString']
          certificate.status = row['statusString']
          certificates << certificate
        end

        certificates
      end

      def download_certificate(certificate)
        list_certificates(certificate.type)

        self.pluggable_parser.default = Mechanize::Download
        download = get(certificate.download_url)
        download.save
        download.filename
      end

      def list_devices
        get('https://developer.apple.com/account/ios/device/deviceList.action')

        regex = /deviceDataURL = "([^"]*)"/
        device_data_url = (page.body.match regex or raise UnexpectedContentError)[1]

        get(device_data_url)
        device_data = page.content
        parsed_device_data = JSON.parse(device_data)

        devices = []
        parsed_device_data['devices'].each do |row|
          device = Device.new
          device.name = row['name']
          device.udid = row['deviceNumber'] # Apple doesn't provide the UDID on this page anymore
          devices << device
        end

        devices
      end

      def add_devices(*devices)
        return if devices.empty?

        get('https://developer.apple.com/account/ios/device/deviceCreate.action')

        begin
          file = Tempfile.new(%w(devices .txt))
          file.write("Device ID\tDevice Name")
          devices.each do |device|
            file.write("\n#{device.udid}\t#{device.name}")
          end
          file.rewind

          form = page.form_with(:name => 'deviceImport') or raise UnexpectedContentError

          upload = form.file_uploads.first
          upload.file_name = file.path
          form.radiobuttons.first.check()
          form.submit

          if form = page.form_with(:name => 'deviceSubmit')
            form.method = 'POST'
            form.field_with(:name => 'deviceNames').name = 'name'
            form.field_with(:name => 'deviceNumbers').name = 'deviceNumber'
            form.submit
          elsif form = page.form_with(:name => 'deviceImport')
            form.submit
          else
            raise UnexpectedContentError
          end

        ensure
          file.close!
        end
      end

      def list_profiles(type = :development)
        url = case type
              when :development
                'https://developer.apple.com/account/ios/profile/profileList.action?type=limited'
              when :distribution
                'https://developer.apple.com/account/ios/profile/profileList.action?type=production'
              else
                raise ArgumentError, 'Provisioning profile type must be :development or :distribution'
              end

        get(url)

        regex = /profileDataURL = "([^"]*)"/
        profile_data_url = (page.body.match regex or raise UnexpectedContentError)[1]

        profile_data_url += case type
                            when :development
                              '&type=limited'
                            when :distribution
                              '&type=production'
                          end

        get(profile_data_url)
        profile_data = page.content
        parsed_profile_data = JSON.parse(profile_data)

        profiles = []
        parsed_profile_data['provisioningProfiles'].each do |row|
          profile = ProvisioningProfile.new
          profile.name = row['name']
          profile.type = type
          profile.app_id = row['appId']['appIdId']
          profile.status = row['status']
          profile.download_url = 'https://developer.apple.com/account/ios/profile/profileContentDownload.action?displayId=' + row['provisioningProfileId']
          profile.edit_url = 'https://developer.apple.com/account/ios/profile/profileEdit.action?provisioningProfileId=' + row['provisioningProfileId']
          profiles << profile
        end
        profiles
      end

      def download_profile(profile)
        list_profiles(profile.type)

        self.pluggable_parser.default = Mechanize::Download
        download = get(profile.download_url)
        download.save
        download.filename
      end

      def manage_devices_for_profile(profile)
        raise ArgumentError unless block_given?

        list_profiles(profile.type)

        get(profile.edit_url)

        on, off = [], []
        page.search('dd.selectDevices div.rows div').each do |row|
          checkbox = row.search('input[type="checkbox"]').first

          device = Device.new
          device.name = row.search('span.title').text rescue nil
          device.udid = checkbox['value'] rescue nil

          if checkbox['checked']
            on << device
          else
            off << device
          end
        end

        devices = yield on, off

        form = page.form_with(:name => 'profileEdit') or raise UnexpectedContentError
        form.checkboxes_with(:name => 'deviceIds').each do |checkbox|
          checkbox.check
          if devices.detect{|device| device.udid == checkbox['value']}
            checkbox.check
          else
            checkbox.uncheck
          end
        end

        form.method = 'POST'
        form.submit
      end

      def list_app_ids
        get('https://developer.apple.com/account/ios/identifiers/bundle/bundleList.action')

        regex = /bundleDataURL = "([^"]*)"/
        bundle_data_url = (page.body.match regex or raise UnexpectedContentError)[1]

        get(bundle_data_url)
        bundle_data = page.content
        parsed_bundle_data = JSON.parse(bundle_data)

        app_ids = []
        parsed_bundle_data['appIds'].each do |row|
          app_id = AppID.new
          app_id.bundle_seed_id = row['prefix'] + '.' + row['identifier']
          app_id.description = row['name']

          #TODO cautious about this part, requires testing

          app_id.development_properties, app_id.distribution_properties = [], []
          row['features'].each do |feature, value|
            if value == true
              app_id.development_properties << feature
            elsif String === value && value != ''
              app_id.development_properties << feature + ': ' + value
            end
          end

          row['enabledFeatures'].each do |feature|
            app_id.distribution_properties << feature
          end

          app_ids << app_id
        end

        app_ids
      end

      #not_working
      def list_pass_type_ids
        get("https://developer.apple.com/ios/manage/passtypeids/index.action")

        pass_type_ids = []
        page.parser.xpath('//fieldset[@id="fs-0"]/table/tbody/tr').each do |row|
          pass_type_id = PassTypeID.new
          pass_type_id.card_id = row.at_xpath('td[@class="checkbox"]/input[@name="selectedValues"]')['value'].to_s.strip rescue nil
          pass_type_id.id = row.at_xpath('td[@class="name"]/strong/text()').to_s.strip rescue nil
          pass_type_id.description = row.at_xpath('td[@class="name"]/text()').to_s.strip rescue nil
          pass_type_id.pass_certificates = row.at_xpath('td[@class="profile"]').inner_text.strip rescue nil

          pass_type_ids << pass_type_id
        end
        pass_type_ids
      end

      #not_working
      def list_pass_certificates(pass_type_id)
        pass_type_id = list_pass_type_ids().delete_if{ |item| item.id != pass_type_id }.shift rescue nil
        return [] if pass_type_id.nil?

        get("https://developer.apple.com/ios/manage/passtypeids/configure.action?displayId=#{pass_type_id.card_id}")

        pass_certificates = []
        page.parser.xpath('//form[@name="form_logginMemberCert"]/table/tr[position()>1]').each do |row|
          pass_certificate = PassCertificate.new
          pass_certificate.name = row.at_xpath('td[1]').inner_text.strip rescue nil
          pass_certificate.status = row.at_xpath('td[2]/span/text()').to_s.strip rescue nil
          pass_certificate.expiration_date = row.at_xpath('td[3]/text()').to_s.strip rescue nil
          pass_certificate.certificate_id = row.at_xpath('td[4]//a[@id="form_logginMemberCert_"]')['href'].to_s.strip.match(/certDisplayId=(.+?)$/)[1] rescue nil

          pass_certificates << pass_certificate unless pass_certificate.certificate_id.nil?
        end
        pass_certificates
      end

      #not_working
      def add_pass_type_id(pass_type_id, description)
        get("https://developer.apple.com/ios/manage/passtypeids/add.action")

        if form = page.form_with(:name => 'save')
          form['cardName'] = description
          form['cardIdentifier'] = pass_type_id

          button = form.button_with(:name => 'submit')
          form.click_button(button)
        end
      end

      #not_working
      def add_pass_certificate(pass_type_id, csr_path, aps_cert_type = 'development')
        pass_type_id = list_pass_type_ids().delete_if{ |item| item.id != pass_type_id }.shift rescue nil
        return if pass_type_id.nil?

        csr_contents = ::File.open(csr_path, "rb").read

        post("https://developer.apple.com/ios/assistant/passtypecommit.action", { 'cardIdValue' => pass_type_id.card_id, 'csrValue' => csr_contents, 'apsCertType' => aps_cert_type })

        JSON.parse(page.content)
      end

      #not_working
      def pass_type_generate(aps_cert_type = 'development')
        post("https://developer.apple.com/ios/assistant/passtypegenerate.action", { 'apsCertType' => aps_cert_type })

        ::JSON.parse(page.content)
      end

      #not_working
      def download_pass_certificate(pass_type_id, certificate_id = nil)
        pass_certificate = (certificate_id.nil? ? list_pass_certificates(pass_type_id).last : list_pass_certificates(pass_type_id).delete_if{ |item| item.certificate_id != certificate_id }.shift) rescue nil
        return nil if pass_certificate.nil?

        self.pluggable_parser.default = Mechanize::Download
        download = get("/ios/manage/passtypeids/downloadCert.action?certDisplayId=#{pass_certificate.certificate_id}")
        download.filename = "#{pass_certificate.certificate_id}.cer"
        download.save
        download.filename
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
          # self.team now stores team ID, not name
          team_option = form.radiobutton_with(:value => self.team)
          team_option.check

          button = form.button_with(:name => 'action:saveTeamSelection!save')
          form.click_button(button)
        end
      end
    end
  end
end
