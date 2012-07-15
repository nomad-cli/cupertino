require 'mechanize'

module Cupertino
  module ProvisioningPortal
    class Device < Struct.new(:name, :udid)
      def to_s
        "#{self.name} #{self.udid}"
      end
    end

    class Certificate < Struct.new(:name, :type, :provisioning_profiles, :expiration_date, :status)
      def to_s
        "#{self.name}"
      end
    end

    class AppID < Struct.new(:bundle_seed_id, :description, :development_properties, :distribution_properties)
      def to_s
        "#{self.bundle_seed_id}"
      end
    end

    class ProvisioningProfile < Struct.new(:name, :type, :app_id, :status)
      def to_s
        "#{self.name}"
      end
    end

    class UnsuccessfulAuthenticationError < RuntimeError; end
  end
end

require 'cupertino/provisioning_portal/helpers'
require 'cupertino/provisioning_portal/agent'
require 'cupertino/provisioning_portal/commands'
