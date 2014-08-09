command :'certificates:list' do |c|
  c.syntax = 'ios certificates:list [development|distribution]'
  c.summary = 'Lists the Certificates'

  c.action do |args, options|
    type = agent.profile_type
    certificates = try{agent.list_certificates(type ||= :development)}

    say_warning "No #{type} certificates found." and abort if certificates.empty?

    table = Terminal::Table.new do |t|
      t << ["Name", "Type", "Expiration Date", "Status"]
      t.add_separator
      certificates.each do |certificate|
        status = case certificate.status
                   when "Issued"
                     certificate.status.green
                   else
                     certificate.status.red
                 end

        t << [certificate.name, certificate.type, certificate.expiration_date, status]
      end
    end

    puts table
  end
end

alias_command :certificates, :'certificates:list'

command :'certificates:download' do |c|
  c.syntax = 'ios certificates:download [development|distribution]'
  c.summary = 'Downloads the Certificates'

  c.action do |args, options|
    type = agent.profile_type
    certificates = try{agent.list_certificates(type ||= :development)}
    profile_name = args.first
    say_warning "No #{type} certificates found." and abort if certificates.empty?
    certificate_index = nil
    if profile_name != nil
      certificate_index = certificates.index{|x| x.name.match "^"+args.first+"$"}
    end

    if certificate_index == nil
      certificate = choose "Select a certificate to download:", *certificates
    else
      certificate = certificates[certificate_index]   
    end

    if filename = agent.download_certificate(certificate)
      say_ok "Successfully downloaded: '#{filename}'"
    else
      say_error "Could not download certificate"
    end
  end
end
