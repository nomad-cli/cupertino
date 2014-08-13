require 'mechanize'
require 'certified'

module Cupertino
  module ProvisioningPortal
    HOST = "developer.apple.com"

    class UnsuccessfulAuthenticationError < RuntimeError; end
    class UnexpectedContentError < RuntimeError; end

    class Device < Struct.new(:name, :udid, :enabled, :device_id)
      def to_s
        "#{self.name} #{self.udid} #{self.enabled}"
      end
    end

    class Certificate < Struct.new(:name, :type, :expiration_date, :status, :download_url)
      def to_s
        "#{self.name}"
      end
    end

    class AppID < Struct.new(:bundle_seed_id, :description, :development_properties, :distribution_properties)
      def to_s
        "#{self.bundle_seed_id}"
      end
    end

    class ProvisioningProfile < Struct.new(:name, :type, :app_id, :status, :expires, :download_url, :edit_url)
      def to_s
        "#{self.name}"
      end
    end

    class PassTypeID < Struct.new(:description, :id, :pass_certificates, :card_id)
      def to_s
        "#{self.id} #{self.description}"
      end
    end

    class PassCertificate < Struct.new(:name, :status, :expiration_date, :certificate_id)
      def to_s
        "#{self.certificate_id}"
      end
    end

    class Team < Struct.new(:name, :programs, :identifier)
      def to_s
        "#{self.name} (#{self.identifier})" + (" [#{self.programs.join(', ')}]" unless self.programs.empty?).to_s
      end
    end
  end
end

require 'cupertino/provisioning_portal/agent'
