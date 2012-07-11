require 'mechanize'

module Cupertino
  module ProvisioningPortal    
    class Device < Struct.new(:name, :udid); end
    class Certificate < Struct.new(:name, :provisioning_profiles, :expiration_date, :status); end
    class AppID < Struct.new(:bundle_seed_id, :description, :development_properties, :distribution_properties); end
    class ProvisioningProfile < Struct.new(:name, :app_id, :status); end
    
    class UnsuccessfulAuthenticationError < RuntimeError; end
  end
end

require 'cupertino/provisioning_portal/helpers'
require 'cupertino/provisioning_portal/agent'
require 'cupertino/provisioning_portal/commands'
