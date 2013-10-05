command :'profiles:list' do |c|
  c.syntax = 'ios profiles:list'
  c.summary = 'Lists the Provisioning Profiles'
  c.description = ''

  c.option '-t', '--type [TYPE]', [:development, :distribution], "Type of profile"

  c.action do |args, options|
    type = options.type || :development
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
  c.description = ''

  c.option '-t', '--type [TYPE]', [:development, :distribution], "Type of profile"

  c.action do |args, options|
    type = options.type || :development
    profiles = try{agent.list_profiles(type)}
    profiles = profiles.select{|profile| profile.status == 'Active'}

    say_warning "No active #{type} profiles found." and abort if profiles.empty?

    name = args.join(" ")
    unless profile = profiles.detect{|p| p.name == name}
      profile = choose "Select a profile to download:", *profiles
    end

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
  c.description = ''

  c.option '-t', '--type [TYPE]', [:development, :distribution], "Type of profile"

  c.action do |args, options|
    type = options.type || :development
    profiles = try{agent.list_profiles(type)}
    profiles = profiles.select{|profile| profile.status == 'Active'}

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
  c.syntax = 'ios profiles:manage:devices'
  c.summary = 'Manage active devices for a development provisioning profile'
  c.description = ''

  c.option '-t', '--type [TYPE]', [:development, :distribution], "Type of profile"

  c.action do |args, options|
    type = options.type || :development
    profiles = try{agent.list_profiles(type)}

    profiles.delete_if{|profile| profile.status == "Invalid"}

    say_warning "No valid #{type} provisioning profiles found." and abort if profiles.empty?

    profile = choose "Select a provisioning profile to manage:", *profiles

    agent.manage_devices_for_profile(profile) do |on, off|
      lines = ["# Comment / Uncomment Devices to Turn Off / On for Provisioning Profile"]
      lines += on.collect{|device| "#{device}"}
      lines += off.collect{|device| "# #{device}"}
      (result = ask_editor lines.join("\n")) or abort("EDITOR undefined. Try run 'export EDITOR=vi'")

      devices = []
      result.split(/\n+/).each do |line|
        next if /^#/ === line
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

alias_command :'profiles:devices', :'profiles:manage:devices'

command :'profiles:manage:devices:add' do |c|
  c.syntax = 'ios profiles:manage:devices:add PROFILE_NAME DEVICE_NAME=DEVICE_ID [...]'
  c.summary = 'Add active devices to a Provisioning Profile'
  c.description = ''

  c.action do |args, options|
    profiles = try{agent.list_profiles(:development) + agent.list_profiles(:distribution)}
    profile = profiles.find {|profile| profile.name == args.first }

    say_warning "No provisioning profiles named #{args.first} were found." and abort unless profile

    agent.manage_devices_for_profile(profile) do |on, off|
      names = args[1..-1].collect{|arg| arg.sub /\=.*/, ''}
      devices = []
      
      names.each do |name|
        device = (on + off).detect{|d| d.name === name}
        say_warning "No device named #{name} was found." and abort unless device
        devices << Device.new(name, device.udid)
      end
      
      on + devices
    end

    say_ok "Successfully added devices to #{args.first}."
  end
end

alias_command :'profiles:devices:add', :'profiles:manage:devices:add'

command :'profiles:manage:devices:remove' do |c|
  c.syntax = 'ios profiles:manage:devices:remove PROFILE_NAME DEVICE_NAME=DEVICE_ID [...]'
  c.summary = 'Remove active devices from a Provisioning Profile.'
  c.description = ''

  c.action do |args, options|
    profiles = try{agent.list_profiles(:development) + agent.list_profiles(:distribution)}
    profile = profiles.find {|profile| profile.name == args.first }

    say_warning "No provisioning profiles named #{args.first} were found." and abort unless profile

    names = args[1..-1].collect{|arg| arg.gsub /\=.*/, ''}

    agent.manage_devices_for_profile(profile) do |on, off|
      on.delete_if{|active| names.include?(active.name)}
    end

    say_ok "Successfully removed devices from #{args.first}."
  end
end

alias_command :'profiles:devices:remove', :'profiles:manage:devices:remove'
