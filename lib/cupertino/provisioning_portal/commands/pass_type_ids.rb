command :'pass_type_ids:list' do |c|
  c.syntax = 'ios pass_type_ids:list'
  c.summary = 'Lists the Pass Type IDs'
  c.description = ''

  c.action do |args, options|
    pass_type_ids = try{agent.list_pass_type_ids}

    say_warning "No pass type IDs found." and abort if pass_type_ids.empty?

    table = Terminal::Table.new do |t|
      t << ["Identifier", "Description"]
      t.add_separator
      pass_type_ids.each do |pass_type_id|

        t << [pass_type_id.id, pass_type_id.description]
      end
    end

    puts table
  end
end

alias_command :pass_type_ids, :'pass_type_ids:list'

command :'pass_type_ids:add' do |c|
  c.syntax = 'ios pass_type_ids:add PASS_TYPE_ID=DESCRIPTION'
  c.summary = 'Adds the pass type ID to the Provisioning Portal'
  c.description = ''

  c.action do |args, options|
    pass_type_id = ask "Pass Type ID:"
    say_error "Pass Type ID must begin with the string 'pass.' and recommended to use reverse-domain name style. Example: pass.domainname.passname" and abort if pass_type_id.end_with?('.') or pass_type_id.index('pass.') != 0 or pass_type_id.match(/^([A-Za-z0-9.-]+)*\*?$/).nil?
    description = ask "Description:"
    say_error "Description cannot contains special characters. (Alphanumeric only) Example: @, &, *, \"" and abort if description.match(/^[\w ]*$/).nil?

    agent.add_pass_type_id(pass_type_id, description)

    say_ok "Added #{pass_type_id}: #{description}"
  end
end
