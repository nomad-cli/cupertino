require 'mechanize'
require 'security'
require 'uri'
require 'json'
require 'date'
require 'time'
require 'logger'

module Cupertino
  module ProvisioningPortal
    class Agent < ::Mechanize
      attr_accessor :username, :password, :team, :team_id

      def initialize
        super
        @csrf_headers = {}
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
            login!
          when /Select Team/
            select_team!
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
          certificate.expiration = (Date.parse(row['expirationDateString']) rescue nil)
          certificate.status = row['statusString']
          certificates << certificate
        end

        certificates
      end

      def create_certificate(type, filename, extra_id)
        get("https://developer.apple.com/account/ios/certificate/certificateCreate.action")
        form_type = case type
                    when :development
                      "5QPB9NHCEI"
                    when :devpush
                      "BKLRAVXMGM"
                    when :production
                      "R58UK2EWSO"
                    when :prodpush
                      "3BQKVH9I2X"
                    # when :passtype
                    #   "Y3B2F3TYSI" #pass type ID needed
                    # when :webpush
                    #   "3T2ZP62QW8" #website push ID needed
                    when :voip
                      "E5D663CMZW"
                    # when :applepay
                    #   "4APLUP237T" #merchant ID needed
                    else
                      raise ArgumentError, "Certificate type must be :development, :devpush, :production, :prodpush, :voip"
                    end

        #Make sure file is valid before hitting Apple's servers
        file = ::File.open(filename)

        #Select Type Page
        form = page.form_with(name: 'certificateSave') or raise UnexpectedContentError
        form.method = 'POST'
        if(type == :devpush or type == :prodpush or type == :voip)
          form.action = "https://developer.apple.com/account/ios/certificate/certificateCreatePush.action" 
        else
          form.action = "https://developer.apple.com/account/ios/certificate/certificateRequest.action"
        end
        form.radiobutton_with(value: form_type).check()
        form.add_field!("formID", "#{rand(100000000)}")
        form.add_field!("clientToken", "undefined")
        form.submit

        #Select Type Page #2 (for Certificate Types which require AppID)
        if(type == :devpush or type == :prodpush or type == :voip)
          form = page.form_with(action: "https://developer.apple.com/account/ios/certificate/certificateCreatePush.action") or raise UnexpectedContentError
          form.method = "POST"
          form.action = "https://developer.apple.com/account/ios/certificate/certificateRequest.action"
          form.field_with(name: "appIdId").option_with(text: extra_id).click
          extra_id = form.field_with(name: "appIdId").option_with(text: extra_id).value
          form.add_field!("types", form_type)
          form.add_field!("formID", "#{rand(100000000)}")
          form.submit
        end

        #Request Page
        form = page.form_with(name: 'certificateRequest') or raise UnexpectedContentError
        form.method = 'POST'
        form.action = "https://developer.apple.com/account/ios/certificate/certificateGenerate.action"
        form.add_field!("types", form_type)
        form.add_field!("formID", "#{rand(100000000)}")
        form.submit

        #Generate Page
        form = page.form_with(name: 'certificateGenerate') or raise UnexpectedContentError
        form.method = 'POST'
        form.action = "https://developer.apple.com/account/ios/certificate/certificateSubmit.action"
        upload = form.file_uploads.first
        upload.file_name = file.path
        if(type == :devpush or type == :prodpush or type == :voip)
          form.field_with(name: "appIdId").value = extra_id
        end
        form.submit
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
          device.udid = row['deviceNumber']
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

      def list_profiles(type = :all)
        url = case type
              when :development
                'https://developer.apple.com/account/ios/profile/profileList.action?type=limited'
              when :distribution
                'https://developer.apple.com/account/ios/profile/profileList.action?type=production'
              when :all
                'https://developer.apple.com/account/ios/profile/profileList.action'
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
                            when :all
                              ''
                            end

        post(profile_data_url)
        @csrf_headers = {
          'csrf' => page.response['csrf'],
          'csrf_ts' => page.response['csrf_ts']
        }

        profile_data = page.content
        parsed_profile_data = JSON.parse(profile_data)

        profiles = []
        parsed_profile_data['provisioningProfiles'].each do |row|
          profile = ProvisioningProfile.new
          profile.name = row['name']
          profile.type = type
          profile.status = row['status']
          profile.expiration = (Time.parse(row['dateExpire']) rescue nil)
          profile.download_url = "https://developer.apple.com/account/ios/profile/profileContentDownload.action?displayId=#{row['provisioningProfileId']}"
          profile.edit_url = "https://developer.apple.com/account/ios/profile/profileEdit.action?provisioningProfileId=#{row['provisioningProfileId']}"
          profile.identifier = row['UUID']
          profiles << profile
        end

        profiles
      end

      def create_profile(name, type, app_id, certificate_id)
        #TODO Simplify this process to bare minimum

        get("https://developer.apple.com/account/ios/profile/profileList.action")
        regex = /profileDataURL = "([^"]*)"/
        profile_data_url = (page.body.match regex or raise UnexpectedContentError)[1]

        post(profile_data_url)
        @csrf_headers = {
          'csrf' => page.response['csrf'],
          'csrf_ts' => page.response['csrf_ts']
        }

        get("https://developer.apple.com/account/ios/profile/profileCreate.action")
        form_type = case type
                    when :development
                      "limited"
                    when :appstore
                      "store"
                    when :adhoc
                      "adhoc"
                    else
                      raise ArgumentError, "Certificate type must be :development, :appstore, :adhoc"
                    end

        #Profile Type Selection
        form = page.form_with(action: 'https://developer.apple.com/account/ios/profile/profileCreate.action') or raise UnexpectedContentError
        form.method = 'POST'
        form.action = "https://developer.apple.com/account/ios/profile/profileCreateApp.action" 
        form.radiobutton_with(value: form_type).check()
        form.add_field!("formID", "#{rand(100000000)}")
        form.submit

        #App ID Selection
        form = page.form_with(action: "https://developer.apple.com/account/ios/profile/profileCreateApp.action") or raise UnexpectedContentError
        form.method = "POST"
        form.action = "https://developer.apple.com/account/ios/profile/profileCreateCertificates.action"
        form.add_field!("distributionType", form_type)
        form.add_field!("formID", "#{rand(100000000)}")
        form.field_with(name: "appIdId").option_with(text: /#{Regexp.escape(app_id)}/).click
        app_id_field = form.field_with(name: "appIdId").option_with(text: /#{Regexp.escape(app_id)}/)
        app_id = app_id_field.value
        app_id_name = app_id_field.text[ /.*(?= \()/ ]
        app_id_prefix = app_id_field.text[ /[A-Z0-9]*(?=\.)/ ]
        app_id_identifier = app_id_field.text[ /\.[^)]+/ ][1..-1]
        form.submit

        #Certificates Selection
        form = page.form_with(action: "https://developer.apple.com/account/ios/profile/profileCreateCertificates.action") or raise UnexpectedContentError
        form.method = "POST"
        form.action = "https://developer.apple.com/account/ios/profile/profileCreateDevices.action"
        form.add_field!("distributionType", form_type)
        form.add_field!("appIdId", app_id)
        form.add_field!("appIdName", app_id_name)
        form.add_field!("appIdPrefix", app_id_prefix)
        form.add_field!("appIdIdentifier", app_id_identifier)
        if certificate_id
          certificate_ids = "[" + certificate_id + "]"
          form.add_field!("certificateCount", 1)
          form.checkboxes_with(name: "certificates", value: certificate_id).check
          certificate_fields = form.checkboxes_with(name: "certificates", value: certificate_id)
        else
          certificate_ids = "[" + form.checkboxes.map(&:value).join(",") + "]"
          form.add_field!("certificateCount", form.checkboxes.count)
          form.checkboxes_with(name: "certificates").each do |cb|
            cb.check
          end
          certificate_fields = form.checkboxes_with(name: "certificates")
        end
        
        form.add_field!("certificateIds", certificate_ids)
        form.add_field!("template", "")
        form.add_field!("formID", "#{rand(100000000)}")
        form.submit

        #Devices Selection
        form = page.form_with(action: "https://developer.apple.com/account/ios/profile/profileCreateDevices.action") or raise UnexpectedContentError
        form.method = "POST"
        form.action = "https://developer.apple.com/account/ios/profile/profileCreateName.action"
        form.add_field!("distributionType", form_type)
        form.add_field!("appIdId", app_id)
        form.add_field!("appIdName", app_id_name)
        form.add_field!("appIdPrefix", app_id_prefix)
        form.add_field!("appIdIdentifier", app_id_identifier)
        form.add_field!("returnFullObjects", "false")
        form.checkboxes_with(name: "devices").each do |cb|
          cb.check
        end
        device_fields = form.checkboxes_with(name: "devices")
        # device_ids = "[" + form.checkboxes_with(name: "devices").map(&:value).join(",") + "]"
        form.add_field!("template", "")
        form.add_field!("formID", "#{rand(100000000)}")
        form.submit
        
        #Name & Generate Profile
        form = page.form_with(name: "profileSubmit") or raise UnexpectedContentError
        form.method = "POST"
        form.field_with(name: "provisioningProfileName").value = name
        form.add_field!("distributionType", form_type)
        form.add_field!("appIdId", app_id)
        # form.add_field!("appIdName", app_id_name)
        # form.add_field!("appIdPrefix", app_id_prefix)
        # form.add_field!("appIdIdentifier", app_id_identifier)
        adssuv = cookies.find{|cookie| cookie.name == 'adssuv'}
        form.add_field!('adssuv-value',Mechanize::Util::uri_unescape(adssuv.value))
        device_fields.each do |cb|
          form.add_field!("devices", cb.value)
        end
        # form.add_field!("deviceCount", device_fields.count)
        certificate_fields.each do |cb|
          form.add_field!("certificates", cb.value)
        end
        # form.add_field!("certificateCount", certificate_fields.count)

        form.submit(nil, @csrf_headers)
        (page.body.match /provisioningProfileId/ or raise UnexpectedContentError)[1]
        return JSON.parse(page.body)['provisioningProfile'] 
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
          device = devices.detect{|d| d.device_id == checkbox['value']}

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
        form.submit(nil, @csrf_headers)
      end

      def list_devices_for_profile(profile)
        devices = list_devices

        begin
          get(profile.edit_url)
        rescue Mechanize::ResponseCodeError
          say_error "Cannot manage devices for #{profile}" and abort
        end

        on, off = [], []
        page.search('dd.selectDevices div.rows div').each do |row|
          checkbox = row.search('input[type="checkbox"]').first
          device = devices.detect{|d| d.device_id == checkbox['value']}

          if checkbox['checked']
            on << device
          else
            off << device
          end
        end

        { :on => on, :off => off }
      end

      def add_app_id(app_id)
        get('https://developer.apple.com/account/ios/identifiers/bundle/bundleList.action')

        regex = /bundleDataURL = "([^"]*)"/
        bundle_data_url = (page.body.match regex or raise UnexpectedContentError)[1]

        post(bundle_data_url)
        @csrf_headers = {
          'csrf' => page.response['csrf'],
          'csrf_ts' => page.response['csrf_ts']
        }

        get("https://developer.apple.com/account/ios/identifiers/bundle/bundleCreate.action")
        form = page.form_with(name: 'bundleSave') or raise UnexpectedContentError
        form.method = 'POST'
        form.action = "https://developer.apple.com/account/ios/identifiers/bundle/bundleConfirm.action"
        form.add_field!("appIdentifierString", app_id.identifier)
        form.field_with(name: "appIdName").value = app_id.description
        form.add_field!("type", "explicit")
        form.field_with(name: "explicitIdentifier").value = app_id.identifier
        form.checkbox_with(name: "push").check
        adssuv = cookies.find{|cookie| cookie.name == 'adssuv'}
        form.add_field!("adssuv-value", Mechanize::Util::uri_unescape(adssuv.value))
        form.add_field!("formID", "#{rand(10000000)}")
        form.add_field!("clientToken", "undefined")
        form.submit

        form = page.form_with(name: 'bundleSubmit') or raise UnexpectedContentError
        form.method = 'POST'
        adssuv = cookies.find{|cookie| cookie.name == 'adssuv'}
        form.add_field!("adssuv-value", Mechanize::Util::uri_unescape(adssuv.value))
        form.add_field!("push", "on")
        form.add_field!("inAppPurchase", "on")
        form.add_field!("gameCenter", "on")
        form.add_field!("explicitIdentifier", app_id.identifier)
        form.add_field!("type", "explicit")
        form.add_field!("appIdName", app_id.description)
        form.add_field!("appIdentifierString", app_id.identifier)
        form.add_field!("formID", "#{rand(100000000)}")
        form.add_field!("clientToken", "undefined")
        form.submit(nil, @csrf_headers) #TODO: Check Repsonse Data for IDs
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
          app_id.identifier = row['identifier']

          app_id.development_properties, app_id.distribution_properties = [], []
          row['features'].each do |feature, value|
            if value == true
              app_id.development_properties << feature
            elsif value.kind_of?(String) && !value.empty?
              app_id.development_properties << "#{feature}: #{value}"
            end
          end

          row['enabledFeatures'].each do |feature|
            app_id.distribution_properties << feature
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
