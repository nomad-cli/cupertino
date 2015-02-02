command :'profiles:list' do |c|
  c.syntax = 'ios profiles:list'
  c.summary = 'Lists the Provisioning Profiles'

  c.option '--type [TYPE]', [:development, :distribution], "Type of profile (development or distribution; defaults to development)"

  c.action do |args, options|
   # type = (options.type.downcase.to_sym if options.type) || :distribution || :development
  #  profiles = try{agent.list_profiles(type)}
  
    type = args.first.downcase.to_sym rescue nil
   # profiles = try{agent.list_profiles(type)}
    profiles = try{agent.list_profiles(:development) + agent.list_profiles(:distribution)}

    say_warning "No #{type} provisioning profiles found." and abort if profiles.empty?

    output = case options.format
             when :csv
               CSV.generate do |csv|
					 csv << ["Profile", "Type", "App ID", "UUID", "Expiration", "Status"]

                 profiles.each do |profile|
					   		csv << [profile.name, profile.type, profile.app_id, profile.identifier, profile.expiration, profile.status]

                 end
               end
             else
               Terminal::Table.new do |t|
					 t << ["Profile", "Type", "App ID", "UUID", "Expiration", "Status"]
                 t.add_separator
                 profiles.each do |profile|
					 	if !profile.name.include? ":"
                   status = case profile.status
                            when "Invalid"
                              profile.status.red
                            when "Expired"
                              profile.status.red
                            else
                              profile.status.green
                            end

					   t << [profile.name, profile.type, profile.app_id, profile.identifier, profile.expiration, status]
					   end
                 end
               end
             end

    puts output
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

command :'profiles:download:allTypes' do |c|
  c.syntax = 'ios profiles:download:allTypes'
  c.summary = 'Downloads all the active Provisioning Profiles'

#   c.option '--type [TYPE]', [:development, :distribution], "Type of profile (development or distribution; defaults to development)"

  c.action do |args, options|
	t5 = Time.now
#     type = (options.type.downcase.to_sym if options.type) || :distribution
#     profiles = try{agent.list_profiles(type)}.select{|profile| profile.status == 'Active'}

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
      lines += off.collect{|device| "#{device.name} #{device.device_id}"}
      lines += on.collect{|device| "#{device.name} #{device.device_id}"}
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

#     args[1..-1].each do |arg|
#       components = arg.strip.gsub(/\"/, '').split(/\=/)
#       device = Device.new
#       device.name = components.first
#       device.udid = components.last
#       devices << device
#     end

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

command :'profiles:manage:devices:list' do |c|
  c.syntax = 'ios profiles:manage:devices:list [NAME]'
  c.summary = 'List devices for a development provisioning profile'

  c.option '--type [TYPE]', [:development, :distribution], "Type of profile (development or distribution; defaults to development)"

  c.action do |args, options|
    type = (options.type.downcase.to_sym if options.type) || :development
    profiles = try{agent.list_profiles(type)}
    profiles.delete_if{|profile| profile.status == "Invalid"}

    say_warning "No valid #{type} provisioning profiles found." and abort if profiles.empty?

    profile = profiles.find{|p| p.name == args.first} || choose("Select a profile:", *profiles)

    list = agent.list_devices_for_profile(profile)

    output = case options.format
             when :csv
               CSV.generate do |csv|
                 csv << ["Device Name", "Device Identifier", "Active"]

                 list.values.each do |devices|
                   devices.each do |device|
                     csv << [device.name, device.udid, "Y"]
                   end
                 end
               end
             else
                title = "Listing devices for provisioning profile #{profile.name}"
                Terminal::Table.new :title => title do |t|
                  t << ["Device Name", "Device Identifier", "Active"]
                  t.add_separator
                  list[:on].each do |device|
                    t << [device.name, device.udid, "Y"]
                  end
                  list[:off].each do |device|
                    t << [device.name, device.udid, "N"]
                  end

                  t.align_column 2, :center
                end
            end

    puts output
  end
end

alias_command :'profiles:devices:list', :'profiles:manage:devices:list'

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
						if !profile.name.include? "AppStore"
							if !profile.name.include? "App Store"
								print profile.name + "\n"
								provisonArray.push(profile.name)
							end
						end
					end
				end
			end
	
			provisonArray.length.times do |i|
				print i.to_s + " " + provisonArray[i] + "\n"
				name = provisonArray[i]
				args = provisonArray[i]
				
				say_ok "Start --  #{name}."
			 
				profiles = try{agent.list_profiles(:development) + agent.list_profiles(:distribution)}
				profile = profiles.find {|profile| profile.name == name }
			
				say_warning "No provisioning profiles named #{name} were found." and abort unless profile
			
				if !profile.name.include? ":"
					if !profile.name.include? "Distribution"
						if !profile.name.include? "AppStore"
							if !profile.name.include? "App Store"
								t1 = Time.now
								agent.manage_devices_for_profile(profile) do |on, off|
								  lines = ["# Comment / Uncomment Devices to Turn Off / On for Provisioning Profile"]
								  lines += off.collect{|device| "#{device.name} #{device.device_id}"}
								  lines += on.collect{|device| "#{device.name} #{device.device_id}"}
								  result = lines.join("\n")
							
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
								t2 = Time.now
								delta = t2 - t1	
							
								say_ok "Successfully added devices to #{name} in #{delta} seconds."
								sleep 6
							end
						end
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

command :'profile.alladdAdhoc' do |c|
	c.syntax = 'ios profile.alladd'
	c.summary = 'Add all devices to all provisioning profiles'
	c.description = ''
	
		c.action do |args, options|
	
			t3 = Time.now
			profiles = try{agent.list_profiles(:distribution)}  # + agent.list_profiles(:distribution)}
	
			provisonArray = Array.new
			
			profiles.each do |profile|
				if !profile.name.include? ":"
					if !profile.name.include? "Distribution"
						if !profile.name.include? "AppStore"
							if !profile.name.include? "App Store"
								print profile.name + "\n"
								provisonArray.push(profile.name)
							end
						end
					end
				end
			end
	
			provisonArray.length.times do |i|
				print i.to_s + " " + provisonArray[i] + "\n"
				name = provisonArray[i]
				args = provisonArray[i]
				
				say_ok "Start --  #{name}."
			 
				profiles = try{agent.list_profiles(:distribution)}
				profile = profiles.find {|profile| profile.name == name }
			
				say_warning "No provisioning profiles named #{name} were found." and abort unless profile
			
				if !profile.name.include? ":"
					if !profile.name.include? "Distribution"
						if !profile.name.include? "AppStore"
							if !profile.name.include? "App Store"
								t1 = Time.now
								agent.manage_devices_for_profile(profile) do |on, off|
								  lines = ["# Comment / Uncomment Devices to Turn Off / On for Provisioning Profile"]
								  lines += off.collect{|device| "#{device.name} #{device.device_id}"}
								  lines += on.collect{|device| "#{device.name} #{device.device_id}"}
								  result = lines.join("\n")
							
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
								t2 = Time.now
								delta = t2 - t1	
							
								say_ok "Successfully added devices to #{name} in #{delta} seconds."
							end
						end
					end
				end
				sleep 8
			end
			t4 = Time.now
			deltaTotal = t4 - t3
			minutesnow = deltaTotal / 60
			print "============================ finished in #{minutesnow} minutes \n"
			
			say_ok "Successfully DONE"
		end
end
