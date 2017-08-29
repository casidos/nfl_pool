# frozen_string_literal: true

class ScoreScraper
  class Game
    attr_reader :away_score, :away_team, :event, :favored_team, :game_time,
                :home_score, :home_team, :id, :spread_odd, :status, :total_odd

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

    def parse_away_score
      scores.first.text
    end

    def parse_event
      @status = parse_status
      @id = event.parent['href'].split('/').last
      @game_time = parse_game_time
      @home_team = teams.last
      @away_team = teams.first

      if status == 'pending'
        @spread_odd, @favored_team = parse_spread_odd
        @total_odd = parse_total_odd
      else
        @away_score = parse_away_score
        @home_score = parse_home_score
      end
    end

    def parse_game_time
      time = event.css('.game-time').first.text
      date = event
             .ancestors('.event-tile')
             .xpath('preceding-sibling::h2')
             .first
             .text
      DateTime.parse "#{date} #{time} #{Time.now.getlocal.zone}"
    end

    def parse_home_score
      scores.last.text
    end

    def parse_status
      clock = event.css('.clock')
      if clock.any?
        clock.first.text.include?('Final') ? 'final' : 'started'
      else
        'pending'
      end
    end

    def parse_total_odd
      odd = parse_away_score.start_with?('T') ?
        parse_away_score :
        parse_home_score
      odd.split(':').last.to_f
    end

    def parse_spread_odd
      odd = parse_away_score.start_with?('T') ?
        [parse_home_score.to_f, home_team] :
        [parse_away_score.to_f, away_team]
    end

    def scores
      @_scores ||= event.css('.odd')
    end

    def teams
      @_teams ||= event.css('.team').map { |t| t.text.strip }
    end
  end
end
