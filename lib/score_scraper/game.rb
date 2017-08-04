class ScoreScraper
  class Game
    attr_reader :away_team, :event, :game_date, :game_time, :home_team, :id,
      :status

    def initialize(event)
      @event = event
      parse_event
      cleanup_unused_vars
      self
    end

    private

    def cleanup_unused_vars
      remove_instance_variable :@event
      remove_instance_variable :@_teams
    end

    def parse_event
      @status = if (clock = event.css('.clock')).any?
                  clock.first.text.include?('Final') ? 'final' : 'started'
                else
                  'pending'
                end

      @id = event.parent['href'].split('/').last
      @game_time = event.css('.game-time').first.text
      @game_date = event.ancestors('.event-tile').xpath('preceding-sibling::h2').first.text

      @home_team = teams.last
      @away_team = teams.first
    end

    def teams
      @_teams ||= event.css('.team').map { |t| t.text.strip }
    end
  end
end
