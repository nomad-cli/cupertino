# Monkey Patch Commander::UI to alias password to avoid conflicts
if defined? Commander
  module Commander::UI
    alias :pw :password
  end
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
              team_map = teams_by_name
              name = team_name || choose("Select a team:", *team_map.keys)
              @team = team_map[name]
            end
          end
        end

        @agent
      end

      def pluralize(n, singular, plural = nil)
        n.to_i == 1 ? "1 #{singular}" : "#{n} #{plural || singular + 's'}"
      end

      def try
        return unless block_given?

        begin
          yield
        rescue UnsuccessfulAuthenticationError
          say_error "Could not authenticate with Apple Developer Center. Check that your username & password are correct, and that your membership is valid and all pending Terms of Service & agreements are accepted. If this problem continues, try logging into https://developer.apple.com/membercenter/ from a browser to see what's going on." and abort
        end
      end
    end
  end
end
