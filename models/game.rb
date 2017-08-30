# frozen_string_literal: true

require './lib/score_scraper'

class Game < Sequel::Model
  class << self
    def generate!(week)
      db.transaction do
        ScoreScraper.new(week: week).games.each do |game|
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
  end

  many_to_many :picks,
    join_table: :odds,
    right_key: :id,
    right_primary_key: :odd_id

  many_to_one :away_team, class: :Team
  many_to_one :home_team, class: :Team
  many_to_one :week

  one_to_one :spread_odd
  one_to_one :total_odd

  def pretty_picks
    ps = picks_dataset.eager_graph(:odd).order(:odd__type).all
    ps.each_with_object({}) do |pick, h|
      k = pick.user.id
      h[k] ||= {}
      if pick.odd.spread?
        h[k][:spread] = pick.team
      else
        h[k][:total] = pick.team
      end
    end
  end

  def total
    away_team_score + home_team_score
  end
end
