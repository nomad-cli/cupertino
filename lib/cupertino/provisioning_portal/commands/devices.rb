command :'devices:list' do |c|
  c.syntax = 'ios devices:list'
  c.summary = 'Lists the Name and ID of Devices in the Provisioning Portal'
  c.description = ''

  c.action do |args, options|
    devices = try{agent.list_devices}

    number_of_devices = devices.compact.length
    number_of_additional_devices = devices.length - number_of_devices

		title = "Listing #{pluralize(number_of_devices, 'device')}. "
		title += "You can register #{pluralize(number_of_additional_devices, 'additional device')}." if number_of_additional_devices > 0

    table = Terminal::Table.new :title => title do |t|
      t << ["Device Name", "Device Identifier"]
      t.add_separator
      devices.compact.each do |device|
        t << [device.name, device.udid]
      end
    end

    puts table
  end
end

alias_command :devices, :'devices:list'

command :'devices:add' do |c|
  c.syntax = 'ios devices:add DEVICE_NAME=DEVICE_ID [...]'
  c.summary = 'Adds the a device to the Provisioning Portal'
  c.description = ''

  c.action do |args, options|
    say_error "Missing arguments, expected DEVICE_NAME=DEVICE_ID" and abort if args.nil? or args.empty?
	listofDevice ||= Array.new
		devices = try{agent.list_devices}
				
		  devices.compact.each do |device|
			#puts [device.udid]
			listofDevice.push(device.udid)
		  end
	
	AddThisDeviceNow = ""
	
    devices = []
    args.each do |arg|
      components = arg.strip.gsub(/"/, '').split(/\=/)
      AddThisDeviceNow = components.last
		if listofDevice.include?(AddThisDeviceNow)
			say_error  "Devices was already in License do not added device " + AddThisDeviceNow
		else
		  device = Device.new
		  device.name = components.first
		  device.udid = components.last
		  devices << device
		end
    end
    
  	
	if devices.length > 0
		say_ok "Add these devices now"
   		puts devices
   		agent.add_devices(*devices)

    	say_ok "Added #{devices.length} #{devices.length == 1 ? 'device' : 'devices'}"
	else
		say_error  "Devices was found do not added device"
    end
  end
end
