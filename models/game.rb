# frozen_string_literal: true

# == Schema Info
#
# away_team_id     integer   indexed      not null
# away_team_score  integer
# final            boolean   indexed      not null, false
# followed         boolean   indexed      not null, false
# game_winner_id   integer   indexed
# home_team_id     integer   indexed      not null
# home_team_score  integer
# id               integer   primary_key  not null, nextval()
# quarter_time     string
# remote_id        string
# starts_at        datetime  indexed      not null
# status           string    indexed      not null
# week_id          integer   indexed      not null
#

require './lib/score_scraper'

class Game < Sequel::Model
  class << self
    def follow!
      DB.transaction do
        pending.update(followed: false)
        pending
          .where(away_team_id: user_teams.map(&:id))
          .or(home_team_id: user_teams.map(&:id))
          .update(followed: true)
      end
    end

    def generate!(week = Week.current.id)
      db.transaction do
        ScoreScraper.new(week: week).games.each do |game|
          teams = [ Team.first(name: game.away_team), Team.first(name: game.home_team)]

          create(
            away_team: teams.first,
            followed: (user_teams & teams).any?,
            home_team: teams.last,
            remote_id: game.id,
            starts_at: game.game_time,
            status: game.status,
            week: Week.first(week: week)
          )
        end
      end
    end

    def update_scores!(week = Week.current.id)
      ScoreScraper.new(week: week).games.each do |game|
        raise 'Game not found' unless (g = Game.first(remote_id: game.id))
        next if game.status == 'pending'
        g.update(
          away_team_score: game.away_score,
          final: game.status == 'final',
          home_team_score: game.home_score,
          quarter_time: game.time_left,
          status: game.status
        )

        g.odds.each { |odd| odd.winner! } if g.final?
      end
    end

    private

    attr_reader :uteams

    def user_teams
      uteams ||= User.all.map(&:team)
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

  dataset_module do
    def followed
      where(followed: true)
    end

    def pending
      where(status: 'pending')
    end

    def began
      where{starts_at < Time.now}
    end

    def unfinished
      exclude(status: %w[final postponed])
    end
  end

  %w[final pending postponed started].each do |s|
    define_method("#{s}?") { status == s }
  end

  def finished?
    %w[final postponed].included? status
  end

  def pretty_picks
    ps = picks_dataset.eager_graph(:odd).order(:odd__type).all
    ps.each_with_object({}) do |pick, h|
      k = pick.user_id
      h[k] ||= {}
      if pick.odd.spread?
        h[k][:spread] = {}
        h[k][:spread][:team_id] = pick.team_id
        h[k][:spread][:won] = pick.won?
      else
        h[k][:total] = {}
        h[k][:total][:team_id] = pick.team_id
        h[k][:total][:won] = pick.won?
      end
    end
  end

  def total
    away_team_score + home_team_score
  end
end
