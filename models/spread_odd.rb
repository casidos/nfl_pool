# frozen_string_literal: true

class SpreadOdd < Odd
  private

  def favored_score
    game.home_team_id == favored_team_id ?
      game.home_team_score :
      game.away_team_score
  end

  def score_difference
    @_score_difference ||= favored_score + odd - unfavored_score
  end

  def spread_winner!
    return favored_team if score_difference.positive?
    return unfavored_team if score_difference.negative?
  end

  def unfavored_score
    game.home_team_id != favored_team_id ?
      game.home_team_score :
      game.away_team_score
  end

  def unfavored_team
    @_unfavored_team ||= game.home_team_id != favored_team_id ?
      game.home_team :
      game.away_team
  end
end
