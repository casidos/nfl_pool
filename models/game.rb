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

    def update_scores!(week)
      ScoreScraper.new(week: week).games.each do |game|
        raise 'Game not found' unless (g = Game.first(remote_id: game.id))
        next if game.status == 'pending'
        g.update(
          away_team_score: game.away_score,
          final: game.status == 'final',
          home_team_score: game.home_score,
          status: game.status
        )

        g.odds.each { |odd| odd.winner! } if g.final?
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

  one_to_many :odds

  one_to_one :spread_odd
  one_to_one :total_odd

  %w[final pending started].each do |s|
    define_method("#{s}?") { status == s }
  end

  def pretty_picks
    ps = picks_dataset.eager_graph(:odd).order(:odd__type).all
    ps.each_with_object({}) do |pick, h|
      k = pick.user.id
      h[k] ||= {}
      if pick.odd.spread?
        h[k][:spread] = {}
        h[k][:spread][:team] = pick.team
        h[k][:spread][:won] = pick.won?
      else
        h[k][:total] = {}
        h[k][:total][:team] = pick.team
        h[k][:total][:won] = pick.won?
      end
    end
  end

  def total
    away_team_score + home_team_score
  end
end
