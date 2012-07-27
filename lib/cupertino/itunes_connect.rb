require 'mechanize'

module Cupertino
  module ITunesConnect

    class SalesSummaryReport < Struct.new(:provider, :provider_country, :sku, :developer, :title, :version, :product_type_identifier, :units, :developer_proceeds, :begin_date, :end_date, :customer_currency, :country_code, :currency_of_proceeds, :apple_identifier, :customer_price, :promo_code, :parent_identifier, :subscription, :period)
      def to_s
        "#{self.sku} - #{self.title}"
      end
    end

    class SalesOptInReport < Struct.new(:first_name, :last_name, :email_address, :postal_code, :apple_identifier, :start_date, :end_date)
      def to_s
        "#{self.name}"
      end
    end

    class UnsuccessfulAuthenticationError < RuntimeError; end
  end
end

require 'cupertino/itunes_connect/helpers'
require 'cupertino/itunes_connect/commands'
