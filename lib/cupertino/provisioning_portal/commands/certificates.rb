command :'certificates:list' do |c|
  c.syntax = 'ios certificates:list'
  c.summary = 'Lists the Certificates'

  c.option '--type [TYPE]', [:development, :distribution], "Type of certificate (development or distribution; defaults to development)"

  c.action do |args, options|
    type = (options.type.downcase.to_sym if options.type) || :development
    certificates = try{agent.list_certificates(type)}

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

  c.option '--type [TYPE]', [:development, :distribution], "Type of certificate (development or distribution; defaults to development)"

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
