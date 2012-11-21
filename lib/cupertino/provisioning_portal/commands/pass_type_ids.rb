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
