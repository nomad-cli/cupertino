command :'certificates:list' do |c|
  c.syntax = 'ios certificates:list [development|distribution]'
  c.summary = 'Lists the Certificates'

  c.action do |args, options|
    type = args.first.downcase.to_sym rescue nil
    certificates = try{agent.list_certificates(type ||= :development)}

    say_warning "No #{type} certificates found." and abort if certificates.empty?

    output = case options.format
             when :csv
               CSV.generate do |csv|
                 csv << ["Name", "Type", "Expiration Date", "Status"]

                 certificates.each do |certificate|
                   csv << [certificate.name, certificate.type, certificate.expiration, certificate.status]
                 end
               end
             else
               Terminal::Table.new do |t|
                 t << ["Name", "Type", "Expiration Date", "Status"]
                 t.add_separator
                 certificates.each do |certificate|
                   status = case certificate.status
                              when "Issued"
                                certificate.status.green
                              else
                                certificate.status.red
                            end

                   t << [certificate.name, certificate.type, certificate.expiration, status]
                 end
               end
             end

    puts output
  end
end

alias_command :certificates, :'certificates:list'

command :'certificates:download' do |c|
  c.syntax = 'ios certificates:download [NAME]'
  c.summary = 'Downloads the Certificates'

  c.option '--type [TYPE]', [:development, :distribution], "Type of profile (development or distribution; defaults to development)"

  c.action do |args, options|
    type = (options.type.downcase.to_sym if options.type) || :development
    certificates = try{agent.list_certificates(type)}

    say_warning "No #{type} certificates found." and abort if certificates.empty?

    certificate = (certificates.detect{|cert| cert.name == args.first} unless args.empty?) || choose("Select a certificate to download:", *certificates)
    if filename = agent.download_certificate(certificate)
      say_ok "Successfully downloaded: '#{filename}'"
    else
      say_error "Could not download certificate"
    end
  end
end

command :'certificates:getid' do |c|
  c.syntax = 'ios certificates:getid [NAME]'
  c.summary = 'Gets the ADC ID of a Certificate by Name'

  c.action do |args, options|
    say_error "Missing arguments, expected [NAME]" and abort if args.nil? or args.empty?
    name = args[0]

    say_error "This is not implemented yet"
  end
end

command :'certificates:create' do |c|
  c.syntax = 'ios certificates:create [CSR] [APPID]'
  c.summary = 'Adds a certificate to the Provisioning Portal'

  c.option '--type [TYPE]', [:development, :production, :devpush, :prodpush, :voip], "Type of profile (development, devpush, production, prodpush, voip; defaults to development)"
  c.option '--download', "Downloads Certificate Created"
  c.option '--internalid', "Outputs the Internal ID of the Created Certificate"

  c.action do |args, options|
    say_error "Missing arguments, expected [CSR] (APPID)" and abort if args.nil? or args.empty?
    type = (options.type.downcase.to_sym if options.type) || :development
    filename = args[0]
    extra_id = (args[1] if args.length == 2) || nil
    certificate = nil

    if options.download or options.internalid
      pre_certs = agent.list_certificates(:development) + agent.list_certificates(:distribution)
    end

    agent.create_certificate(type, filename, extra_id)    
    if options.download
      say_ok "Assuming created certificate from CSR #{filename} as a #{type} certificate, waiting a few seconds to download." unless options.internalid
      5.times do
        sleep 3 #wait a few seconds for the certificate to generate
        post_certs = agent.list_certificates(:development) + agent.list_certificates(:distribution)
        certificate = (post_certs - pre_certs).first
        if certificate
          agent.download_certificate(certificate)
          say_ok "Downloaded created certificate #{certificate}." unless options.internalid
          break
        end
      end
      unless certificate
        say_error "Could not download the created certificate over 5 tries." and abort
      end
    else
      say_ok "Assuming created certificate from CSR #{filename} as a #{type} certificate." unless options.internalid
    end

    if options.internalid
      unless certificate
        5.times do
          sleep 3 #wait a few seconds for the certificate to generate
          post_certs = agent.list_certificates(:development) + agent.list_certificates(:distribution)
          certificate = (post_certs - pre_certs).first
          break if certificate
        end
      end
      if certificate
        say_ok CGI.parse(URI.parse(certificate.download_url).query)['displayId'].first
      else
        say_error "Could not output certificate ID that was created" and abort
      end
    end
  end
end
