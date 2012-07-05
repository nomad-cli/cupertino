command :'devices:list' do |c|
  c.syntax = 'ios devices:list'
  c.summary = 'Lists the Name and ID of Devices in the Provisioning Portal'
  c.description = ''
  
  c.action do |args, options|
    devices = agent.list_devices
    
    say_ok "Devices:"
    devices.each do |device|
      log device.name, device.udid
    end
  end
end

alias_command :devices, :'devices:list'
