# frozen_string_literal: true

class Odd < Sequel::Model
  class << self
    def generate!(week)
      db.transaction do
        ScoreScraper.new(week: week).games.each do |game|
          raise 'Game not found' unless (g = Game.first(remote_id: game.id))

          SpreadOdd.create(
            game: g,
            odd: game.spread_odd,
            favored_team: Team.first(name: game.favored_team)
          )
          TotalOdd.create(game: g, odd: game.total_odd)
        end
      end
    end
  end

  plugin :single_table_inheritance, :type

  many_to_one :favored_team, class: :Team
  many_to_one :game
  many_to_one :winning_team, class: :Team

  def spread?
    false
  end

  def total?
    false
  end

  def winner!
    team = send("#{type.downcase.gsub('odd', '')}_winner!") || Team.push
    update(winning_team: team)
    team
  end
end
