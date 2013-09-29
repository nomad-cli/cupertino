command :'profiles:list' do |c|
  c.syntax = 'ios profiles:list [development|distribution]'
  c.summary = 'Lists the Provisioning Profiles'
  c.description = ''

  c.action do |args, options|
    type = args.first.downcase.to_sym rescue nil
    profiles = try{agent.list_profiles(type ||= :development)}

    say_warning "No #{type} provisioning profiles found." and abort if profiles.empty?

    table = Terminal::Table.new do |t|
      t << ["Profile", "App ID", "Profile ID", "UUID", "Status"]
      t.add_separator
      profiles.each do |profile|
        status = case profile.status
                 when "Invalid"
                   profile.status.red
                 else
                   profile.status.green
                 end

        t << [profile.name, profile.app_id, profile.id, profile.uuid, status]
      end
    end

    puts table
  end
end

alias_command :profiles, :'profiles:list'

command :'profiles:download' do |c|
  c.syntax = 'ios profiles:download'
  c.summary = 'Downloads the Provisioning Profiles'
  c.description = ''

  c.action do |args, options|
    type = args.first.downcase.to_sym rescue nil
	profiles = try{agent.list_profiles(:development) + agent.list_profiles(:distribution)}
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


command :'profile.alladd' do |c|
	c.syntax = 'ios profile.alladd'
	c.summary = 'Add all devices to all provisioning profiles'
	c.description = ''
	
		c.action do |args, options|
	
			t3 = Time.now
			profiles = try{agent.list_profiles(:development) + agent.list_profiles(:distribution)}
	
			provisonArray = Array.new
			
			profiles.each do |profile|
				if !profile.name.include? ":"
					if !profile.name.include? "Distribution"
						print profile.name + "\n"
						provisonArray.push(profile.name)
					end
				end
			end
	
			provisonArray.length.times do |i|
				print i.to_s + " " + provisonArray[i] + "\n"
				name = provisonArray[i]
				args = provisonArray[i]
				
				#say_ok "Start --  #{name}."
			 
				profiles = try{agent.list_profiles(:development) + agent.list_profiles(:distribution)}
				profile = profiles.find {|profile| profile.name == name }
			
				say_warning "No provisioning profiles named #{name} were found." and abort unless profile
			
				if !profile.name.include? ":"
					if !profile.name.include? "Distribution"
						t1 = Time.now
						agent.manage_devices_for_profile(profile) do |on, off|
						  lines = ["# Comment / Uncomment Devices to Turn Off / On for Provisioning Profile"]
						  lines += on.collect{|device| "#{device}"}
						  lines += off.collect{|device| "#{device}"}
						  result = lines.join("\n")
					
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
						t2 = Time.now
						delta = t2 - t1	
					
						say_ok "Successfully added devices to #{name} in #{delta} seconds."
					end
				end
			end
			t4 = Time.now
			deltaTotal = t4 - t3
			minutesnow = deltaTotal / 60
			print "============================ finished in #{minutesnow} minutes \n"
			
			say_ok "Successfully DONE"
		end
end


command :'profiles:download:all' do |c|
  c.syntax = 'ios profiles:download:all [development|distribution]'
  c.summary = 'Downloads all the active Provisioning Profiles'
  c.description = ''

  c.action do |args, options|
	t5 = Time.now
    type = args.first.downcase.to_sym rescue nil
	profiles = try{agent.list_profiles(:development) + agent.list_profiles(:distribution)}
    profiles = profiles.find_all{|profile| profile.status == 'Active'}

    say_warning "No active #{type} profiles found." and abort if profiles.empty?
    profiles.each do |profile|
     if !profile.name.include? ":"
		if filename = agent.download_profile(profile)
			say_ok "Successfully downloaded: '#{filename}'"
		  else
			say_error "Could not download profile: '#{profile.name}'"
		  end
		end
    end
	t6 = Time.now
	deltaTotal2 = t6 - t5
	minutesnow2 = deltaTotal2 / 60
	print "============================ finished in #{minutesnow2} minutes \n"
  end
end

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
      lines += off.collect{|device| "# #{device}"}
      lines += on.collect{|device| "#{device}"}
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

    devices = []
    args[1..-1].each do |arg|
      components = arg.strip.gsub(/\"/, '').split(/\=/)
      device = Device.new
      device.name = components.first
      device.udid = components.last
      devices << device
    end

    agent.manage_devices_for_profile(profile) do |on, off|
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

    devices = []
    args[1..-1].each do |arg|
      components = arg.strip.gsub(/\"/, '').split(/\=/)
      device = Device.new
      device.name = components.first
      device.udid = components.last
      devices << device
    end

    agent.manage_devices_for_profile(profile) do |on, off|
      on.delete_if {|active| devices.any? {|inactive| inactive.udid == active.udid }}
    end

    say_ok "Successfully removed devices from #{args.first}."
  end
end

alias_command :'profiles:devices:remove', :'profiles:manage:devices:remove'
