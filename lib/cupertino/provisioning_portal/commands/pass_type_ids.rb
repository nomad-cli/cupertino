command :'pass_type_ids:list' do |c|
  c.syntax = 'ios pass_type_ids:list'
  c.summary = 'Lists the Pass Type IDs'
  c.description = ''
  c.option '-u', '--username USER', 'Username'
  c.option '-p', '--password PASSWORD', 'Password'
  c.option '-tm', '--team TEAM', 'Team'

  c.action do |args, options|
    agent.username = options.username unless options.username.nil?
    agent.password = options.password unless options.password.nil?
    agent.team = options.team unless options.team.nil?

    pass_type_ids = try{agent.list_pass_type_ids}

    say_warning "No pass type IDs found." and abort if pass_type_ids.empty?

    table = Terminal::Table.new do |t|
      t << ["Card ID", "Identifier", "Description", "Pass Certificates"]
      t.add_separator
      pass_type_ids.each do |pass_type_id|
        t << [pass_type_id.card_id, pass_type_id.id, pass_type_id.description, pass_type_id.pass_certificates]
      end
    end

    puts table
  end
end

alias_command :pass_type_ids, :'pass_type_ids:list'

command :'pass_type_ids:add' do |c|
  c.syntax = 'ios pass_type_ids:add PASS_TYPE_ID --description STRING'
  c.summary = 'Adds the Pass Type to the Provisioning Portal'
  c.description = ''
  c.option '-d', '--description DESCRIPTION', 'Description'
  c.option '-u', '--username USER', 'Username'
  c.option '-p', '--password PASSWORD', 'Password'
  c.option '-tm', '--team TEAM', 'Team'

  c.action do |args, options|
    agent.username = options.username unless options.username.nil?
    agent.password = options.password unless options.password.nil?
    agent.team = options.team unless options.team.nil?

    pass_type_id = args.first
    pass_type_id ||= ask "Pass Type ID:"
    say_error "Pass Type ID must begin with the string 'pass.' and use reverse-domain name style. Example: pass.domainname.passname" and abort unless PASS_TYPE_ID_REGEXP === pass_type_id

    description = options.description
    description ||= ask "Description (alphanumeric characters and spaces only):"
    say_error "Invalid description. Only alphanumeric characters and spaces are allowed." and abort unless /^[\w ]*$/ === description

    agent.add_pass_type_id(pass_type_id, description)

    say_ok "Added #{pass_type_id}: #{description}"
  end
end

command :'pass_type_ids:certificates:list' do |c|
  c.syntax = 'ios pass_type_ids:certificates:list PASS_TYPE_ID'
  c.summary = 'Lists the Pass Certificates for a specific Pass Type ID'
  c.description = ''
  c.option '-u', '--username USER', 'Username'
  c.option '-p', '--password PASSWORD', 'Password'
  c.option '-tm', '--team TEAM', 'Team'

  c.action do |args, options|
    agent.username = options.username unless options.username.nil?
    agent.password = options.password unless options.password.nil?
    agent.team = options.team unless options.team.nil?

    pass_type_id = args.first || determine_pass_type_id!

    pass_certificates = try{agent.list_pass_certificates(pass_type_id)}
    say_warning "No pass certificates found for Pass Type ID (#{pass_type_id})." and abort if pass_certificates.empty?

    table = Terminal::Table.new do |t|
      t << ["Name", "Status", "Expiration Date", "Certificate ID"]

      t.add_separator

      pass_certificates.each do |pass_certificate|
        t << [pass_certificate.name, pass_certificate.status, pass_certificate.expiration_date, pass_certificate.certificate_id]
      end
    end

    puts table
  end
end

alias_command :'pass_type_ids:certificates', :'pass_type_ids:certificates:list'

command :'pass_type_ids:certificates:add' do |c|
  c.syntax = 'ios pass_type_ids:certificates:add PASS_TYPE_ID --csr STRING'
  c.summary = 'Adds the pass certificate for pass type ID to the Provisioning Portal'
  c.description = ''
  c.option '-r', '--csr CERTIFICATE_SIGNING_REQUEST', 'Path to Certificate Signing Request (CSR)'
  c.option '-u', '--username USER', 'Username'
  c.option '-p', '--password PASSWORD', 'Password'
  c.option '-tm', '--team TEAM', 'Team'

  c.action do |args, options|
    agent.username = options.username unless options.username.nil?
    agent.password = options.password unless options.password.nil?
    agent.team = options.team unless options.team.nil?

    pass_type_id = args.first || determine_pass_type_id!

    csr = options.csr
    csr ||= ask "CSR Path:"
    say_error "No Certificate Signing Request found at path #{csr}." and abort if not ::File.exists?(csr)

    result = agent.add_pass_certificate(pass_type_id, csr)
    say_error "Failed to configure #{pass_type_id}" and abort if not result["acknowledgement"] or result["pageError"]

    say_ok "Configured #{pass_type_id}. Apple is generating the certificate..."

    catch(:generated) do
      say_ok "Certificate generated and is ready to be downloaded." and abort
    end

    # Wait up to 30 seconds for certificate to be generated
    6.times do
      throw :generated if agent.pass_type_generate["certStatus"] rescue false
      sleep 5
    end

    say_warning "Certificate is not generated after waiting for 30 seconds, aborting further monitoring. You might have reached the maximum number of certificates generated (5) for a pass." and abort
  end
end

command :'pass_type_ids:certificates:download' do |c|
  c.syntax = 'ios pass_type_ids:certificates:download PASS_TYPE_ID [--certificate_id STRING]'
  c.summary = 'Adds the pass certificate for pass type ID to the Provisioning Portal'
  c.description = ''
  c.option '-c', '--certificate_id ID', 'Certificate ID'
  c.option '-u', '--username USER', 'Username'
  c.option '-p', '--password PASSWORD', 'Password'
  c.option '-tm', '--team TEAM', 'Team'

  c.action do |args, options|
    agent.username = options.username unless options.username.nil?
    agent.password = options.password unless options.password.nil?
    agent.team = options.team unless options.team.nil?

    pass_type_id = args.first || determine_pass_type_id!

    certificate_id = options.certificate_id

    if filename = agent.download_pass_certificate(pass_type_id, certificate_id)
      say_ok "Successfully downloaded: '#{filename}'"
    else
      say_error "Could not download pass certificate"
    end
  end
end

private

PASS_TYPE_ID_REGEXP = /^pass\.([A-Za-z0-9-]+\.?)+(\*|[^\.])$/

def determine_pass_type_id!
  pass_type_ids = try{agent.list_pass_type_ids}

  case pass_type_ids.length
  when 0
    say_error "No Pass Types found." and abort
  when 1
    pass_type_id = pass_type_ids.first
  else
    pass_type_id = choose "Select a Pass Type", *pass_type_ids
  end
end
