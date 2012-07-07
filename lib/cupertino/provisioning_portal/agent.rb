require 'mechanize'

module Cupertino
  module ProvisioningPortal
    class Agent < ::Mechanize
      attr_accessor :username, :password, :team

      def initialize
        super
        self.user_agent_alias = 'Mac Safari'
      end

      def get(uri, parameters = [], referer = nil, headers = {})
        3.times do
          super(uri, parameters, referer, headers)

          case page.title
          when %r{Sign in with your Apple ID}
            login! and redo
          when %r{Select Your Team}
            select_team! and redo
          else
            return page
          end
        end
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
          certificate.provisioning_profiles = row.at_xpath('td[@class="profiles"]/text()').to_s.strip.split(/\n+/) rescue []
          certificate.expiration_date = row.at_xpath('td[@class="date"]/text()').to_s.strip rescue nil
          certificate.status = row.at_xpath('td[@class="status"]/text()').to_s.strip rescue nil
          certificates << certificate
        end
        certificates
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
          profile.name = row.at_xpath('td[@class="profile"]/text()').to_s.strip rescue nil
          profile.app_id = row.at_xpath('td[@class="appid"]/text()').to_s.strip rescue nil
          profile.status = row.at_xpath('td[@class="statusXcode"]/text()').to_s.strip rescue nil
          profiles << profile
        end
        profiles
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

          btn = form.button_with(:name => 'action:saveTeamSelection!save')
          form.click_button(btn)
        end
      end
    end
  end
end
