# Monkey Patch Commander::UI to alias password to avoid conflicts
module Commander::UI
  alias :pw :password
end

class String
  include Term::ANSIColor
end

module Cupertino
  module ProvisioningPortal
    module Helpers
      def agent
        unless @agent
          @agent = Cupertino::ProvisioningPortal::Agent.new

          @agent.instance_eval do
            def username
              @username ||= ask "Username:"
            end

            def password
              @password ||= pw "Password:"
            end

            def team
              teams = page.form_with(:name => 'saveTeamSelection').field_with(:name => 'memberDisplayId').options.collect(&:text)
              @team ||= choose "Select a team:", *teams
            end
          end
        end

        @agent
      end
      
      def pluralize(n, singular, plural = nil)
        n.to_i == 1 ? "1 #{singular}" : "#{n} #{plural || singular + 's'}"
      end
    end
  end
end
