# frozen_string_literal: true

class Odd < Sequel::Model
  plugin :single_table_inheritance, :type

  many_to_one :favored_team, class: :Team
  many_to_one :game
  many_to_one :winning_team, class: :Team

  def winner!
    team = send("#{type.downcase.gsub('odd', '')}_winner!") || Team.push
    update(winning_team: team)
    team
  end
end
