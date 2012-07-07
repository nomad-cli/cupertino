command :'profiles:list' do |c|
  c.syntax = 'ios profiles:list'
  c.summary = 'Lists the Provisioning Profiles in the Provisioning Portal'
  c.description = ''

  c.action do |args, options|
    profiles = agent.list_profiles

    table = Terminal::Table.new do |t|
      t << ["Profile", "App ID", "Status"]
      t.add_separator
      profiles.each do |profile|
        status = case profile.status
                 when "Invalid"
                   profile.status.red
                 else
                   profile.status.green
                 end

        t << [profile.name, profile.app_id, status]
      end
    end

    puts table
  end
end

alias_command :profiles, :'profiles:list'
