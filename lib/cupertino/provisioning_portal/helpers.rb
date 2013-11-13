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

            def team_id
              teams = []

              page.form_with(:name => 'saveTeamSelection').radiobuttons.each do |radio|
                primary = page.search(".label-primary[for=\"#{radio.dom_id}\"]").first.text.strip
                secondary = page.search(".label-secondary[for=\"#{radio.dom_id}\"]").first.text.strip
                team_id = radio.value
                name = "#{primary}, #{secondary} (#{team_id})"
                teams << [name, radio.value]
              end

              team_names = teams.collect(&:first)
              team_ids   = teams.collect(&:last)

              if @team.nil?
                selected_team_name = choose "Select a team:", *team_names
                teams.detect { |t| t.first == selected_team_name }.last
              elsif team_ids.member? @team
                @team
              elsif team = teams.detect { |t| t.first.start_with?(@team) }
                team.last
              else
                say_error "Team should be a name or identifier" and abort
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
