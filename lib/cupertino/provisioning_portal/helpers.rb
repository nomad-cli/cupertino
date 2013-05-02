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
              # we're working with radio buttons instead of a drop down menu
              teams = page.form_with(:name => 'saveTeamSelection').radiobuttons
              # create a dictionary of team.value -> team name
              formatted_teams = {}
              teams.each do |team|
                # we can't use team.label as this only returns the last label
                # Apple use two labels with the same for="", we want the first
                formatted_teams[team.value] = page.search("label[for=\"#{team.dom_id}\"]").first.text.strip
              end
              teamname = choose "Select a team:", *formatted_teams.values
              @team ||= formatted_teams.key(teamname)
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
