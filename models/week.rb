# frozen_string_literal: true

class Week < Sequel::Model
  class << self
    def current
      now = Time.now
      ds = Week.where(season: now.year).order(:betting_starts_at)

      ds.where{betting_starts_at <= now}.last ||
        ds.first
    end
  end

  dataset_module do
    def for(season = 2017)
      where(season: season).order(:week)
    end
  end

  many_through_many :picks, [
    [:games, :week_id, :id],
    [:odds, :game_id, :id]
  ],
    right_primary_key: :odd_id

  many_to_many :odds, join_table: :games, right_key: :id, right_primary_key: :game_id

  one_to_many :games, order: :starts_at

  def betting_period?
    Time.now >= betting_starts_at &&
      !betting_ended?
  end

  def betting_ended?
    Time.now > betting_ends_at
  end

  def last_week
    Week[id - 1]
  end

  def picks_for(user)
    picks_dataset.where(user: user).all.each_with_object({}) do |pick, h|
      h[pick.odd_id] = pick.team
    end
  end

  def pot
    return @_pot if defined?(@_pot)
    return unless betting_tier

    buy_in = User.dataset.count * betting_tier
    previous_pot = betting_tier > 1 ? previous_week.pot : 0
    @_pot = buy_in + previous_pot
  end
end
