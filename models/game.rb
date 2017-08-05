require './lib/score_scraper'

class Game < Sequel::Model
  class << self
    def generate!(week)
      db.transaction do
        scraper(week).games.each do |game|
          create(
            away_team: Team.first(name: game.away_team),
            home_team: Team.first(name: game.home_team),
            remote_id: game.id,
            starts_at: game.game_time,
            status: game.status,
            week: Week.first(week: week)
          )
        end
      end
    end

    private

    def scraper(week = nil)
      @_scraper ||= ScoreScraper.new(week: week)
    end
  end

  many_to_one :away_team, class: :Team
  many_to_one :home_team, class: :Team
  many_to_one :week
end