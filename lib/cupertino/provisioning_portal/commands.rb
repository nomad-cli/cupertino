include Cupertino::ProvisioningPortal
include Cupertino::ProvisioningPortal::Helpers

$:.push File.expand_path('../', __FILE__)

require 'commands/certificates'
require 'commands/devices'
require 'commands/profiles'
