command :'certificates:list' do |c|
  c.syntax = 'ios certificates:list [development|distribution]'
  c.summary = 'Lists the Certificates'
  c.description = ''

  c.action do |args, options|
    type = args.first.downcase.to_sym rescue nil
    certificates = agent.list_certificates(type ||= :development)

    say_warning "No #{type} certificates found." and abort if certificates.empty?

    table = Terminal::Table.new do |t|
      t << ["Name", "Provisioning Profiles", "Expiration Date", "Status"]
      t.add_separator
      certificates.each do |certificate|
        status = case certificate.status
                 when "Issued"
                   certificate.status.green
                 else
                   certificate.status.red
                 end

        t << [certificate.name, certificate.provisioning_profiles.join("\n"), certificate.expiration_date, status]
      end
    end

    puts table
  end
end

alias_command :certificates, :'certificates:list'
