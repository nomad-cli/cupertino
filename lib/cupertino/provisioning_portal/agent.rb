require 'mechanize'
require 'security'
require 'uri'
require 'json'
require 'logger'

module Cupertino
  module ProvisioningPortal
    class Agent < ::Mechanize
      attr_accessor :username, :password, :team

      def initialize
        super

        self.user_agent_alias = 'Mac Safari'

        self.log ||= Logger.new(STDOUT)
        self.log.level = Logger::ERROR

        if ENV['HTTP_PROXY']
          uri = URI.parse(ENV['HTTP_PROXY'])
          user = ENV['HTTP_PROXY_USER'] if ENV['HTTP_PROXY_USER']
          password = ENV['HTTP_PROXY_PASSWORD'] if ENV['HTTP_PROXY_PASSWORD']

          set_proxy(uri.host, uri.port, user || uri.user, password || uri.password)
        end

        pw = Security::InternetPassword.find(:server => Cupertino::ProvisioningPortal::HOST)
        @username, @password = pw.attributes['acct'], pw.password if pw
      end

      def username=(value)
          @username = value
          
          pw = Security::InternetPassword.find(:a => self.username, :server => Cupertino::ProvisioningPortal::HOST)
          @password = pw.password if pw
      end

      def get(uri, parameters = [], referer = nil, headers = {})
        uri = ::File.join("https://#{Cupertino::ProvisioningPortal::HOST}", uri) unless /^https?/ === uri

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

        post(certificate_data_url)
        certificate_data = page.content
        parsed_certificate_data = JSON.parse(certificate_data)

        certificates = []
        parsed_certificate_data['certRequests'].each do |row|
          certificate = Certificate.new
          certificate.name = row['name']
          certificate.type = type
          certificate.download_url = "https://developer.apple.com/account/ios/certificate/certificateContentDownload.action?displayId=#{row['certificateId']}&type=#{row['certificateTypeDisplayId']}"
          certificate.expiration_date = row['expirationDateString']
          certificate.status = row['statusString']
          certificates << certificate
        end

        certificates
      end

      def download_certificate(certificate)
        list_certificates(certificate.type)

        self.pluggable_parser.default = Mechanize::Download
        download = post(certificate.download_url)
        download.save
        download.filename
      end

      def list_devices
        get('https://developer.apple.com/account/ios/device/deviceList.action')

        regex = /deviceDataURL = "([^"]*)"/
        device_data_url = (page.body.match regex or raise UnexpectedContentError)[1]

        post(device_data_url)

        device_data = page.content
        parsed_device_data = JSON.parse(device_data)

        devices = []
        parsed_device_data['devices'].each do |row|
          device = Device.new
          device.name = row['name']
          device.enabled = (row['status'] == 'c' ? 'Y' : 'N')
          device.device_id = row['deviceId']
          device.udid = row['deviceName']
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

        self.pluggable_parser.default = Mechanize::File
        get(url)

        regex = /profileDataURL = "([^"]*)"/
        profile_data_url = (page.body.match regex or raise UnexpectedContentError)[1]

        profile_data_url += case type
                            when :development
                              '&type=limited'
                            when :distribution
                              '&type=production'
                            end

        post(profile_data_url)

        profile_data = page.content
        parsed_profile_data = JSON.parse(profile_data)

        profiles = []
        parsed_profile_data['provisioningProfiles'].each do |row|
          profile = ProvisioningProfile.new
          profile.name = row['name']
          profile.type = type
          profile.app_id = row['appId']['appIdId']
          profile.status = row['status']
          profile.download_url = "https://developer.apple.com/account/ios/profile/profileContentDownload.action?displayId=#{row['provisioningProfileId']}"
          profile.edit_url = "https://developer.apple.com/account/ios/profile/profileEdit.action?provisioningProfileId=#{row['provisioningProfileId']}"
          profiles << profile
        end

        profiles
      end

      def download_profile(profile)
        self.pluggable_parser.default = Mechanize::Download
        download = get(profile.download_url)
        download.save
        download.filename
      end

      def manage_devices_for_profile(profile)
        raise ArgumentError unless block_given?

        devices = list_devices

        begin
          get(profile.edit_url)
        rescue Mechanize::ResponseCodeError
          say_error "Cannot manage devices for #{profile}" and abort
        end

        on, off = [], []
        page.search('dd.selectDevices div.rows div').each do |row|
          checkbox = row.search('input[type="checkbox"]').first
          device = devices.detect{|device| device.device_id == checkbox['value']}

          if checkbox['checked']
            on << device
          else
            off << device
          end
        end

        devices = yield on, off

        form = page.form_with(:name => 'profileEdit') or raise UnexpectedContentError
        form.checkboxes_with(:name => 'deviceIds').each do |checkbox|
          if devices.detect{|device| device.device_id == checkbox['value']}
            checkbox.check
          else
            checkbox.uncheck
          end
        end

        adssuv = cookies.find{|cookie| cookie.name == 'adssuv'}
        form.add_field!('adssuv-value', Mechanize::Util::uri_unescape(adssuv.value))

        form.method = 'POST'
        form.submit
      end

      def list_app_ids
        get('https://developer.apple.com/account/ios/identifiers/bundle/bundleList.action')

        regex = /bundleDataURL = "([^"]*)"/
        bundle_data_url = (page.body.match regex or raise UnexpectedContentError)[1]

        post(bundle_data_url)
        bundle_data = page.content
        parsed_bundle_data = JSON.parse(bundle_data)

        app_ids = []
        parsed_bundle_data['appIds'].each do |row|
          app_id = AppID.new
          app_id.bundle_seed_id = [row['prefix'], row['identifier']].join(".")
          app_id.description = row['name']

          app_id.development_properties, app_id.distribution_properties = [], []
          row['features'].each do |feature, value|
            if value == true
              if feature == "push"
                if row['isDevPushEnabled'] == true
                  app_id.development_properties << "push:Enabled"
                else
                  app_id.development_properties << "push:Configurable"
                end
              else 
                app_id.development_properties << "#{feature}:Enabled"
              end
            end
          end

          row['enabledFeatures'].each do |feature|
            if feature == "push"
              if row['isProdPushEnabled'] == true
                app_id.distribution_properties << "push:Enabled"
              else
                app_id.distribution_properties << "push:Configurable"
              end
            else 
              app_id.distribution_properties << "#{feature}:Enabled"
           end
          end

          app_ids << app_id
        end

        app_ids
      end

      private

      def login!
        if form = page.forms.first
          form.fields_with(type: 'text').first.value = self.username
          form.fields_with(type: 'password').first.value = self.password

          form.submit
        end
      end

      def select_team!
        if form = page.form_with(:name => 'saveTeamSelection')
          team_option = form.radiobutton_with(:value => self.team_id)
          team_option.check

          button = form.button_with(:name => 'action:saveTeamSelection!save')
          form.click_button(button)
        end
      end
    end
  end
end
