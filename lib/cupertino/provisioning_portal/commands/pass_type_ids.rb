command :'pass_type_ids:list' do |c|
  c.syntax = 'ios pass_type_ids:list'
  c.summary = 'Lists the Pass Type IDs'
  c.description = ''

  c.action do |args, options|
    pass_type_ids = try{agent.list_pass_type_ids}

    say_warning "No pass type IDs found." and abort if pass_type_ids.empty?

    table = Terminal::Table.new do |t|
      t << ["Card ID","Identifier", "Description", "Pass Certificates"]
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
  c.syntax = 'ios pass_type_ids:add --pass_type_id STRING --description STRING'
  c.summary = 'Adds the pass type ID to the Provisioning Portal'
  c.description = ''
  c.option '--pass_type_id STRING', String, 'Pass Type ID'
  c.option '--description STRING', String, 'Description'

  c.action do |args, options|
    pass_type_id = options.pass_type_id
    pass_type_id ||= ask "Pass Type ID:"
    say_error "Pass Type ID must begin with the string 'pass.' and recommended to use reverse-domain name style. Example: pass.domainname.passname" and abort if pass_type_id.end_with?('.') or pass_type_id.index('pass.') != 0 or pass_type_id.match(/^([A-Za-z0-9.-]+)*\*?$/).nil?
    description = options.description
    description ||= ask "Description:"
    say_error "Description cannot contains special characters. (Alphanumeric only) Example: @, &, *, \"" and abort if description.match(/^[\w ]*$/).nil?

    agent.add_pass_type_id(pass_type_id, description)

    say_ok "Added #{pass_type_id}: #{description}"
  end
end

command :'pass_type_ids:configure' do |c|
  c.syntax = 'ios pass_type_ids:configure --pass_type_id STRING --csr_path STRING'
  c.summary = 'Configure the pass type ID in the Provisioning Portal'
  c.description = ''
  c.option '--pass_type_id STRING', String, 'Pass Type ID'
  c.option '--csr_path STRING', String, 'CSR Path'
  
  c.action do |args, options|
    pass_type_id = options.pass_type_id
    pass_type_id ||= ask "Pass Type ID:"
    say_error "Pass Type ID must begin with the string 'pass.' and recommended to use reverse-domain name style. Example: pass.domainname.passname" and abort if pass_type_id.end_with?('.') or pass_type_id.index('pass.') != 0 or pass_type_id.match(/^([A-Za-z0-9.-]+)*\*?$/).nil?
    csr_path = options.csr_path
    csr_path ||= ask "CSR Path:"
    say_error "Must be a valid path to a CSR." and abort if !::File.exists?(csr_path)
    
    result = agent.configure_pass_type_id(pass_type_id, csr_path)
    say_error "Failed to configure #{pass_type_id}" and abort if !result["acknowledgement"] or result["pageError"]
    
    say_ok "Configured #{pass_type_id}. Apple is generating the certificate..."
    
    certificate_generated = false
    6.times do
      
      certificate_generated = agent.pass_type_generate["certStatus"] rescue false
      break if certificate_generated
      sleep(5.0)
    end
    
    say_warning "Certificate is not generated after waiting for 30 seconds, aborting further monitoring. You might have reached the maximum number of certificates generated (5) for a pass." and abort unless certificate_generated
    
    say_ok "Certificate generated and is ready to be downloaded."
  end
end