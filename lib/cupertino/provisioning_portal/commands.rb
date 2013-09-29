include Cupertino::ProvisioningPortal
include Cupertino::ProvisioningPortal::Helpers

global_option('-u', '--username USER', 'Username') { |arg| agent.username = arg unless arg.nil? }
global_option('-p', '--password PASSWORD', 'Password') { |arg| agent.password = arg unless arg.nil? }
global_option('-tm', '--team TEAM', 'Team') { |arg| agent.team = arg unless arg.nil? }

global_option('-i','--info', 'Set log level to INFO and higher') { agent.log_level(Logger::INFO) }
global_option('-d','--debug','Set log level to DEBUG and higher (that is, all log messages)') { agent.log_level(Logger::DEBUG) }

require 'cupertino/provisioning_portal/commands/certificates'
require 'cupertino/provisioning_portal/commands/devices'
require 'cupertino/provisioning_portal/commands/profiles'
require 'cupertino/provisioning_portal/commands/app_ids'
require 'cupertino/provisioning_portal/commands/login'
require 'cupertino/provisioning_portal/commands/logout'
