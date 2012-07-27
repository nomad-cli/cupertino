require 'mechanize'

module Cupertino
  module ITunesConnect
    class UnsuccessfulAuthenticationError < RuntimeError; end
  end
end

require 'cupertino/itunes_connect/helpers'
require 'cupertino/itunes_connect/commands'
