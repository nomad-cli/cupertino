command :'profiles:list' do |c|
  c.syntax = 'ios profiles:list'
  c.summary = 'Lists the Provisioning Profiles'

  c.option '--type [TYPE]', [:development, :distribution], "Type of profile (development or distribution; defaults to development)"

  c.action do |args, options|
    type = (options.type.downcase.to_sym if options.type) || :development
    profiles = try{agent.list_profiles(type)}

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

command :'profiles:download' do |c|
  c.syntax = 'ios profiles:download [PROFILE_NAME]'
  c.summary = 'Downloads the Provisioning Profiles'

  c.option '--type [TYPE]', [:development, :distribution], "Type of profile (development or distribution; defaults to development)"

  c.action do |args, options|
    type = (options.type.downcase.to_sym if options.type) || :development
    profiles = try{agent.list_profiles(type)}
    profiles = profiles.select{|profile| profile.status == 'Active'}

    say_warning "No active #{type} profiles found." and abort if profiles.empty?

    profile = profiles.find{|p| p.name == args.join(" ")} || choose("Select a profile:", *profiles)

    if filename = agent.download_profile(profile)
      say_ok "Successfully downloaded: '#{filename}'"
    else
      say_error "Could not download profile"
    end
  end
end

command :'profiles:download:all' do |c|
  c.syntax = 'ios profiles:download:all'
  c.summary = 'Downloads all the active Provisioning Profiles'

  c.option '--type [TYPE]', [:development, :distribution], "Type of profile (development or distribution; defaults to development)"

  c.action do |args, options|
    type = (options.type.downcase.to_sym if options.type) || :development
    profiles = try{agent.list_profiles(type)}.select{|profile| profile.status == 'Active'}

    say_warning "No active #{type} profiles found." and abort if profiles.empty?
    profiles.each do |profile|
      if filename = agent.download_profile(profile)
        say_ok "Successfully downloaded: '#{filename}'"
      else
        say_error "Could not download profile: '#{profile.name}'"
      end
    end
  end
end

command :'profiles:manage:devices' do |c|
  c.syntax = 'ios profiles:manage:devices [PROFILE_NAME]'
  c.summary = 'Manage active devices for a development provisioning profile'

  c.option '--type [TYPE]', [:development, :distribution], "Type of profile (development or distribution; defaults to development)"

  c.action do |args, options|
    type = (options.type.downcase.to_sym if options.type) || :development
    profiles = try{agent.list_profiles(type)}
    profiles.delete_if{|profile| profile.status == "Invalid"}

    say_warning "No valid #{type} provisioning profiles found." and abort if profiles.empty?

    profile = profiles.find{|p| p.name == args.first} || choose("Select a profile:", *profiles)

    agent.manage_devices_for_profile(profile) do |on, off|
      lines = ["# Comment / Uncomment Devices to Turn Off / On for Provisioning Profile"]
      lines += on.collect{|device| "#{device.name} #{device.device_id}"}
      lines += off.collect{|device| "# #{device.name} #{device.device_id}"}
      (result = ask_editor lines.join("\n")) or abort("EDITOR undefined. Try run 'export EDITOR=vi'")

      devices = []
      result.split(/\n+/).each do |line|
        next if /^#/ === line
        components = line.split(/\s+/)
        device = Device.new
        device.device_id = components.pop
        device.name = components.join(" ")
        devices << device
      end

      devices
    end

    say_ok "Successfully managed devices"
  end
end

alias_command :'profiles:devices', :'profiles:manage:devices'

command :'profiles:manage:devices:add' do |c|
  c.syntax = 'ios profiles:manage:devices:add [PROFILE_NAME] DEVICE_NAME=DEVICE_ID [...]'
  c.summary = 'Add active devices to a Provisioning Profile'

  c.action do |args, options|
    profiles = try{agent.list_profiles(:development) + agent.list_profiles(:distribution)}
    profile = profiles.find{|p| p.name == args.first} || choose("Select a profile:", *profiles)

    names = args[1..-1].select{|arg| /\=/ === arg}.collect{|arg| arg.sub(/\=.*/, '')}
    devices = []

    agent.manage_devices_for_profile(profile) do |on, off|
      names.each_with_index do |name, idx|
        next if idx == 0 and name == profile.name

        device = (on + off).detect{|d| d.name === name}
        say_warning "No device named #{name} was found." and next unless device
        devices << Device.new(name, device.udid, "Y", device.device_id)
      end

      on + devices
    end

    case devices.length
    when 0
      say_warning "No devices were added"
    else
      say_ok "Successfully added #{pluralize(devices.length, 'device', 'devices')} to #{profile}."
    end
  end
end

alias_command :'profiles:devices:add', :'profiles:manage:devices:add'

command :'profiles:manage:devices:remove' do |c|
  c.syntax = 'ios profiles:manage:devices:remove PROFILE_NAME DEVICE_NAME=DEVICE_ID [...]'
  c.summary = 'Remove active devices from a Provisioning Profile.'

  c.action do |args, options|
    profiles = try{agent.list_profiles(:development) + agent.list_profiles(:distribution)}
    profile = profiles.find{|p| p.name == args.first} || choose("Select a profile:", *profiles)

    say_warning "No provisioning profiles named #{args.first} were found." and abort unless profile

    names = args.collect{|arg| arg.gsub(/\=.*/, '')}

		removed = []

    agent.manage_devices_for_profile(profile) do |on, off|
			removed = on.select{|device| names.include?(device.name)}
      on - removed
    end

    case removed.length
    when 0
      say_warning "No devices were removed"
    else
      say_ok "Successfully removed #{pluralize(removed.length, 'device', 'devices')} from #{profile}."
    end
  end
end

alias_command :'profiles:devices:remove', :'profiles:manage:devices:remove'

command :'profiles:devices:list' do |c|
  c.syntax = 'ios profiles:devices:list [PROFILE_NAME]'
  c.summary = 'List devices for a development provisioning profile'

  c.option '--type [TYPE]', [:development, :distribution], "Type of profile (development or distribution; defaults to development)"

  c.action do |args, options|
    type = (options.type.downcase.to_sym if options.type) || :development
    profiles = try{agent.list_profiles(type)}
    profiles.delete_if{|profile| profile.status == "Invalid"}

    say_warning "No valid #{type} provisioning profiles found." and abort if profiles.empty?

    profile = profiles.find{|p| p.name == args.first} || choose("Select a profile:", *profiles)

    list = agent.list_devices_for_profile(profile)

    title = "Listing devices for provisioning profile #{profile.name}"

    table = Terminal::Table.new :title => title do |t|
      t << ["Device Name", "Device Identifier", "Active"]
      t.add_separator
      list[:on].each do |device|
        t << [device.name, device.udid, "Y"]
      end
      list[:off].each do |device|
        t << [device.name, device.udid, "N"]
      end
    end

    table.align_column 2, :center

    puts table
  end
end

alias_command :'profiles:list_devices', :'profiles:manage:devices:list'
