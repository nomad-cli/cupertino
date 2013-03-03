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
    name = args[1].downcase rescue nil
    add_all = args[2].downcase rescue false
    profiles = try{agent.list_profiles(type ||= :development)}

    say_warning "No #{type} provisioning profiles found." and abort if profiles.empty?

    if name.nil?
      profile = choose "Select a provisioning profile to manage:", *profiles
    else
      profiles = profiles.find_all{|profile| profile.name == name}
      say_warning "No active #{name} profile found." and abort if profiles.empty?
      profile = profiles[0]
    end

    agent.manage_devices_for_profile(profile) do |on, off|
      lines = ["# Comment / Uncomment Devices to Turn Off / On for Provisioning Profile"]
      lines += on.collect{|device| "#{device}"}
      if add_all
        lines += off.collect{|device| "#{device}"}
        result = lines.join("\n")
      else  
        lines += off.collect{|device| "# #{device}"}
        result = ask_editor lines.join("\n")
      end

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

command :'profiles:download' do |c|
  c.syntax = 'ios profiles:download'
  c.summary = 'Downloads the Provisioning Profiles'
  c.description = ''

  c.action do |args, options|
    type = args.first.downcase.to_sym rescue nil
    name = args[1].downcase rescue nil
    profiles = try{agent.list_profiles(type ||= :development)}
    active_profiles = profiles.find_all{|profile| profile.status == 'Active'}
    say_warning "No active #{type} profiles found." and abort if active_profiles.empty?
    if name.nil?
      profile = choose "Select a profile to download:", *active_profiles
    else
      profiles = profiles.find_all{|profile| profile.name == name}
      say_warning "No active #{name} profile found." and abort if profiles.empty?
      profile = profiles[0]
    end

    if filename = agent.download_profile(profile)
      say_ok "Successfully downloaded: '#{filename}'"
    else
      say_error "Could not download profile"
    end
  end
end

