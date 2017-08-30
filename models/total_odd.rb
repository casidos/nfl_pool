# frozen_string_literal: true

class TotalOdd < Odd
  def total?
    true
  end

  private

  def total_winner!
    return Team.over if odd < game.total
    return Team.under if odd > game.total
  end
end
