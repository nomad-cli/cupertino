include Cupertino::ProvisioningPortal
include Cupertino::ProvisioningPortal::Helpers

global_option('-u', '--username USER', 'Username') { |arg| agent.username = arg unless arg.nil? }
global_option('-p', '--password PASSWORD', 'Password') { |arg| agent.password = arg unless arg.nil? }
global_option('-tm', '--team TEAM', 'Team') { |arg| agent.team_name = arg unless arg.nil? }

require 'cupertino/provisioning_portal/commands/certificates'
require 'cupertino/provisioning_portal/commands/devices'
require 'cupertino/provisioning_portal/commands/profiles'
require 'cupertino/provisioning_portal/commands/app_ids'
require 'cupertino/provisioning_portal/commands/login'
require 'cupertino/provisioning_portal/commands/logout'
