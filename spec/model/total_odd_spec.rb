# frozen_string_literal: true

require_relative 'spec_helper'

describe TotalOdd do
  it 'Over Wins' do
    o = odd(25)
    o.winner!.must_equal Team.over
  end

  it 'Away Wins' do
    o = odd(35)
    o.winner!.must_equal Team.under
  end

  it 'Push' do
    o = odd(30)
    o.winner!.must_equal Team.push
  end

  private

  def game
    Game.create(
      away_team: Team[1],
      away_team_score: 10,
      home_team: Team[2],
      home_team_score: 20,
      starts_at: Time.now,
      status: 'pending',
      week: Week[1]
    )
  end

  def odd(odd)
    TotalOdd.create(game: game, odd: odd)
  end
end
