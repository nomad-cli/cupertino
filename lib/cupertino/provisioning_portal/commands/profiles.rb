
command :'profiles:list2' do |c|
	c.syntax = 'ios profiles:list [development|distribution]'
	c.summary = 'Lists the Provisioning Profiles'
	c.description = ''
	

	c.action do |args, options|
		type = args.first.downcase.to_sym rescue nil
		profiles = try{agent.list_profiles(:development) + agent.list_profiles(:distribution)}
		
		say_warning "No #{type} provisioning profiles found." and abort if profiles.empty?

		ThisAraay = Array.new
		
			profiles.each do |profile|
				#print profile.name + "\n"
				ThisAraay.push(profile.name)
			end
		
	end
end

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

command :'profiles:download' do |c|
	c.syntax = 'ios profiles:download'
	c.summary = 'Downloads the Provisioning Profiles'
	c.description = ''
		
		c.action do |args, options|
			type = args.first.downcase.to_sym rescue nil
			name = args[1] rescue nil
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

command :'profiles:manage:devices' do |c|
	c.syntax = 'ios profiles:manage:devices'
	c.summary = 'Manage active devices for a development provisioning profile'
	c.description = ''
	
		c.action do |args, options|
			type = args.first.downcase.to_sym rescue nil
			name = args[1] rescue nil
			
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
					lines += off.collect{|device| "#{device}"}
					result = lines.join("\n")
			
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
		
			say_ok "Successfully managed devices #{type} #{profile}"
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

command :'profile.alladd' do |c|
	c.syntax = 'ios profile.alladd'
	c.summary = 'Add all devices to all provisioning profiles'
	c.description = ''
	
		c.action do |args, options|
	
			profiles = try{agent.list_profiles(:development) + agent.list_profiles(:distribution)}
	
			provisonArray = Array.new
			
				profiles.each do |profile|
					print profile.name + "\n"
					provisonArray.push(profile.name)
				end
	
				provisonArray.length.times do |i|
					print i.to_s + " " + provisonArray[i] + "\n"
					name = provisonArray[i]
					profiles = try{agent.list_profiles(:development) + agent.list_profiles(:distribution)}
				
					say_warning "No #{type} provisioning profiles found." and abort if profiles.empty?
				
					profiles = profiles.find_all{|profile| profile.name == name}
							
					say_warning "No active #{name} profile found." and abort if profiles.empty?
					profile = profiles[0]
			
					agent.manage_devices_for_profile(profile) do |on, off|
						lines = ["# Comment / Uncomment Devices to Turn Off / On for Provisioning Profile"]
						lines += on.collect{|device| "#{device}"}
						lines += off.collect{|device| "#{device}"}
						result = lines.join("\n")
				
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
					say_ok "Successfully managed devices - #{name}"
				end
			print "============================\n"
			
			say_ok "Successfully DONE"
		end
end

command :'profile.alldownload' do |c|
	c.syntax = 'ios profile.alldownload'
	c.summary = 'Downlaod all provisioning profiles'
	c.description = ''
	
		c.action do |args, options|
			#type = args.first.downcase.to_sym rescue nil
			#name = args[1] rescue nil
	
			profiles = try{agent.list_profiles(:development) + agent.list_profiles(:distribution)}
	
			provisonArray = Array.new
			
				profiles.each do |profile|
					print profile.name + "\n"
					provisonArray.push(profile.name)
				end
			
				provisonArray.length.times do |h|
					print h.to_s + " " + provisonArray[h] + "\n"
					name = provisonArray[h]
					#print "type #{type}\n"
					print "name #{name}\n"
					profiles = try{agent.list_profiles(:development) + agent.list_profiles(:distribution)}
					profiles = profiles.find_all{|profile| profile.name == name}
					say_warning "No active #{name} profile found." and abort if profiles.empty?
					profile = profiles[0]
					
					# delete the file if it exists
					path_to_file = name + ".mobileprovision"
					File.delete(path_to_file) if File.exist?(path_to_file)
					
					path_to_file1 = name + ".mobileprovision.zip"
					File.delete(path_to_file1) if File.exist?(path_to_file1)
		
				
						if filename = agent.download_profile(profile)
							say_ok "Successfully downloaded: '#{filename}'"
						else
							say_error "Could not download profile #{filename}"
						end
				end
			sleep 1
			say_ok "Successfully DONE"
		end
end
