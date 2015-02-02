command :'devices:list' do |c|
  c.syntax = 'ios devices:list'
  c.summary = 'Lists the Name and ID of Devices in the Provisioning Portal'

  c.action do |args, options|
    devices = try{agent.list_devices}

    say_warning "No devices found" and abort if devices.empty?

    output = case options.format
             when :csv
               CSV.generate do |csv|
                 csv << ["Device Name", "Device Identifier", "Enabled"]

                 devices.compact.each do |device|
                   csv << [device.name, device.udid, device.enabled]
                 end
               end
             else
               number_of_devices = devices.compact.length
               number_of_additional_devices = devices.length - number_of_devices

               title = "Listing #{pluralize(number_of_devices, 'device')} "
               title += "(You can register #{pluralize(number_of_additional_devices, 'additional device')})" if number_of_additional_devices > 0

               Terminal::Table.new :title => title do |t|
                 t << ["Device Name", "Device Identifier", "Enabled"]
                 t.add_separator
                 devices.compact.each do |device|
                   t << [device.name, device.udid, device.enabled]
                 end

                 t.align_column 2, :center
               end
             end

    puts output
  end
end

alias_command :devices, :'devices:list'

command :'devices:add' do |c|
  c.syntax = 'ios devices:add DEVICE_NAME=DEVICE_ID [...]'
  c.summary = 'Adds a device to the Provisioning Portal'

  c.action do |args, options|
    say_error "Missing arguments, expected DEVICE_NAME=DEVICE_ID" and abort if args.nil? or args.empty?

	listofDevice ||= Array.new
		devices = try{agent.list_devices}
				
		  devices.compact.each do |device|
			#puts [device.udid]
			listofDevice.push(device.udid)
		  end
	
	#puts listofDevice
	AddThisDeviceNow = ""

    devices = []
    args.each do |arg|
      components = arg.gsub(/"/, '').split(/\=/)
      AddThisDeviceNow = components.last
		if listofDevice.include?(AddThisDeviceNow)
			say_error  "Devices was already in License do not added device " + AddThisDeviceNow
    	else
		  device = Device.new
		  device.name = components.first
		  device.udid = components.last
		  say_warning "Invalid UDID: #{device.udid}" and next unless /\h{40}/ === device.udid
		  devices << device
    	end
    end

	if devices.length > 0
		say_ok "Add these devices now"
   		puts devices
    	agent.add_devices(*devices)

    	say_ok "Added #{devices.length} #{devices.length == 1 ? 'device' : 'devices'}"
    	say_ok "Added #{pluralize(devices.length, 'device')}"
	else
		say_error  "Devices was found do not added device"
    end

  end
end
