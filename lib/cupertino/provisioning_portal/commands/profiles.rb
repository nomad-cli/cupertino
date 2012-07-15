command :'profiles:list' do |c|
  c.syntax = 'ios profiles:list [development|distribution]'
  c.summary = 'Lists the Provisioning Profiles'
  c.description = ''

  c.action do |args, options|
    type = args.first.downcase.to_sym rescue nil
    profiles = try{agent.list_profiles(type ||= :development)}

    say_warning "No #{type} provisioning profiles found." and abort if profiles.empty?

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

command :'profiles:manage:devices' do |c|
  c.syntax = 'ios profiles:manage:devices'
  c.summary = 'Manage active devices for a development provisioning profile'
  c.description = ''

  c.action do |args, options|
    type = args.first.downcase.to_sym rescue nil
    profiles = try{agent.list_profiles(:development)}

    say_warning "No #{type} provisioning profiles found." and abort if profiles.empty?

    profile = choose "Select a provisioning profile to manage:", *profiles

    agent.manage_devices_for_profile(profile) do |on, off|
      lines = ["# Comment / Uncomment Devices to Turn Off / On for Provisioning Profile"]
      lines += on.collect{|device| "#{device}"}
      lines += off.collect{|device| "# #{device}"}
      result = ask_editor lines.join("\n")

      devices = []
      result.split(/\n+/).each do |line|
        next if /^\#/ === line
        components = line.split(/\s+/)
        device = Device.new
        device.udid = components.pop
        device.name = components.join(" ")
        devices << device
      end

      devices
    end

    say_ok "Successfully managed devices"
  end
end

alias_command :'profiles:manage', :'profiles:manage:devices'
