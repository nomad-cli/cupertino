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
              teams = []
              page.form_with(:name => 'saveTeamSelection').radiobuttons.each do |radio|
                primary = page.search(".label-primary[for=\"#{radio.dom_id}\"]").first.text.strip
                secondary = page.search(".label-secondary[for=\"#{radio.dom_id}\"]").first.text.strip
                name = "#{primary}, #{secondary}"
                teams << [name, radio.value]
              end

              @team_name ||= choose "Select a team:", *teams.collect(&:first)
              if team = teams.detect{|e| e.first == @team_name}
                @team = team.last
              else
                team_names = teams.map { |t| "\"#{t.first}\"" }.join(', ')
                say_error "Team should be one of the following: #{team_names}" and abort
              end
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
