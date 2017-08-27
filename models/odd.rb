# frozen_string_literal: true

class Odd < Sequel::Model
  plugin :single_table_inheritance, :type

  many_to_one :favored_team, class: :Team
  many_to_one :game
  many_to_one :team

  def winner!
    update(team: send("#{type.downcase.gsub('odd', '')}_winner!") || Team.push)
  end
end
