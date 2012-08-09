# Monkey Patch Commander::UI to alias password to avoid conflicts
module Commander::UI
  alias :pw :password
end

module Cupertino
  module ProvisioningPortal
    module Helpers
      def hasharray_to_table(hav, title)
        Terminal::Table.new :title => title do |t|
          headers = []
          hav[0].keys.each do |header|
            headers << "#{header}"
          end
          t << headers
          t << :separator

          hav.each do |rv|
            row = []
            rv.values.each do |cv|
              row << "#{cv}"
            end
            t << row
          end
        end
      end
    end
  end
end


class String
  include Term::ANSIColor
end
