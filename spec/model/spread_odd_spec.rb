# frozen_string_literal: true

require_relative 'spec_helper'

describe SpreadOdd do
  describe 'Home Favored' do
    let(:game) { new_game(10, 20) }

    it 'Home Wins' do
      o = odd(game, home, -5)
      o.winner!.must_equal home
    end

    it 'Away Wins' do
      o = odd(game, home, -15)
      o.winner!.must_equal away
    end

    it 'Push' do
      o = odd(game, home, -10)
      o.winner!.must_equal push
    end
  end

  describe 'Away Favored' do
    let(:game) { new_game(20, 10) }

    it 'Away Wins' do
      o = odd(game, away, -5)
      o.winner!.must_equal away
    end

    it 'Home Wins' do
      o = odd(game, away, -15)
      o.winner!.must_equal home
    end

    it 'Push' do
      o = odd(game, away, -10)
      o.winner!.must_equal push
    end
  end

  private

  def away
    Team[2]
  end

  def new_game(away_score, home_score)
    Game.create(
      away_team: away,
      away_team_score: away_score,
      home_team: home,
      home_team_score: home_score,
      starts_at: Time.now,
      status: 'pending',
      week: Week[1]
    )
  end

  def home
    Team[1]
  end

  def odd(game, team, odd)
    SpreadOdd.create(favored_team: team, game: game, odd: odd)
  end

  def push
    Team.push
  end
end
