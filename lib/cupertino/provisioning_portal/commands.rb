include Cupertino::ProvisioningPortal

require 'cupertino/provisioning_portal/helpers'
include Cupertino::ProvisioningPortal::Helpers

global_option('-u', '--username USER', 'Username') { |arg| agent.username = arg unless arg.nil? }
global_option('-p', '--password PASSWORD', 'Password') { |arg| agent.password = arg unless arg.nil? }
global_option('--team TEAM', 'Team') { |arg| agent.team = arg if arg }
global_option('--info', 'Set log level to INFO') { agent.log.level = Logger::INFO }
global_option('--debug', 'Set log level to DEBUG') { agent.log.level = Logger::DEBUG }
global_option('-q', '--quiet', 'quiet mode') { |arg| agent.quiet_mode = true }

require 'cupertino/provisioning_portal/commands/certificates'
require 'cupertino/provisioning_portal/commands/devices'
require 'cupertino/provisioning_portal/commands/profiles'
require 'cupertino/provisioning_portal/commands/app_ids'
require 'cupertino/provisioning_portal/commands/login'
require 'cupertino/provisioning_portal/commands/logout'
