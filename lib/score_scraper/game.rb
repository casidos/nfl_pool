# frozen_string_literal: true

class ScoreScraper
  class Game
    attr_reader :away_score, :away_team, :event, :favored_team, :game_time,
                :home_score, :home_team, :id, :spread_odd, :status, :time_left,
                :total_odd

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

    def clock
      @_clock ||= event.css('.clock')
    end

    def final?
      clock.first.text.include?('Final')
    end

    def parse_away_score
      scores.first.text.strip.to_i
    end

    def parse_event
      @status = parse_status
      @time_left = parse_time_left
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
      return unless (time = event.css('.game-time').first&.text)
      date = event
             .ancestors('.event-tile')
             .xpath('preceding-sibling::h2')
             .first
             .text
      DateTime.parse "#{date} #{time} #{Time.now.getlocal.zone}"
    end

    def parse_home_score
      scores.last.text.strip.to_i
    end

    def parse_status
      return 'pending' unless clock.any?
      return 'final' if final?
      'started'
    end

    def parse_time_left
      return if clock.empty?
      return if clock.first.text.include?('Final')
      clock.first.text.split(' ').reverse.join(' - ')
    end

    def parse_total_odd
      odd = (o = odds.first.text).start_with?('T') ?
        o :
        odds.last.text
      odd.split(':').last.to_f
    end

    def parse_spread_odd
      odd = (o = odds.first.text).start_with?('T') ?
        [odds.last.text.to_f, home_team] :
        [o.to_f, away_team]
    end

    def odds
      @_odds ||= event.css('.odd')
    end

    def scores
      @_scores ||= event.css('.score')
    end

    def teams
      @_teams ||= event.css('.team').map { |t| t.text.strip }
    end
  end
end
