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
    profiles = try{agent.list_profiles(type ||= :development)}

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

command :'profiles:download' do |c|
  c.syntax = 'ios profiles:download'
  c.summary = 'Downloads the Provisioning Profiles'
  c.description = ''

  c.action do |args, options|
    type = args.first.downcase.to_sym rescue nil
    profiles = try{agent.list_profiles(type ||= :development)}
    profiles = profiles.find_all{|profile| profile.status == 'Active'}

    say_warning "No active #{type} profiles found." and abort if profiles.empty?
    profile = choose "Select a profile to download:", *profiles
    if filename = agent.download_profile(profile)
      say_ok "Successfully downloaded: '#{filename}'"
    else
      say_error "Could not download profile"
    end
  end
end

command :'profiles:download:all' do |c|
  c.syntax = 'ios profiles:download:all'
  c.summary = 'Downloads all the Provisioning Profiles'
  c.description = ''

  c.action do |args, options|
    type = args.first.downcase.to_sym rescue nil
    if(type == nil)
      type = :all;
    end

    profiles = nil;

    if(type == :all)
      profiles_dev = try{agent.list_profiles(:development)}
      profiles_dev = profiles_dev.find_all{|profile| profile.status == 'Active'}

      profiles_dist = try{agent.list_profiles(:distribution)}
      profiles_dist = profiles_dist.find_all{|profile| profile.status == 'Active'}

      profiles = profiles_dev + profiles_dist

    else
      profiles = try{agent.list_profiles(type ||= :development)}
      profiles = profiles.find_all{|profile| profile.status == 'Active'}
    end

    say_warning "No active #{type} profiles found." and abort if profiles.empty?

    profiles.each do |p|
      if filename = agent.download_profile(p)
        say_ok "Successfully downloaded: '#{filename}'"
      else
        say_error "Could not download profile"
      end
    end
  end
end
