# frozen_string_literal: true

# == Schema Info
#
# betting_ends_at    datetime  indexed      not null
# betting_starts_at  datetime  indexed      not null
# betting_tier       integer
# id                 integer   primary_key  not null, nextval()
# pot                integer
# season             integer   indexed      not null
# week               integer   indexed      not null
#

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
  many_to_many :winners, class: :User, join_table: :users_weeks, right_key: :user_id

  one_through_one :winner, class: :User, join_table: :users_weeks, right_key: :user_id

  one_to_many :debts
  one_to_many :games, order: :starts_at

  def betting_period?
    Time.now >= betting_starts_at &&
      !betting_ended?
  end

  def betting_ended?
    Time.now > betting_ends_at
  end

  def correct_picks(odd_type = nil)
    return @_correct_picks if defined?(@_correct_picks)
    ds = picks_dataset
    ds = ds.send(odd_type) if odd_type
    user_ids = ds.won.map(:user_id)

    @_correct_picks ||= user_ids.each_with_object({}) do |uid, h|
      c = user_ids.count(uid)
      h[c] ||= []
      next if h[c].include? uid
      h[c] << uid
    end
  end

  def extend_time(hours)
    update(betting_ends_at: betting_ends_at + (60 * 60 * hours))
  end

  def games_finished?
    games_dataset.followed.unfinished.empty?
  end

  def last_week
    Week[id - 1]
  end

  def next_week
    Week[id + 1]
  end

  def perfect_week?
    return false unless winner?
    winner.correct_picks_week_dataset(self).count == games_dataset.followed.count
  end

  def picks_for(user)
    picks_dataset.where(user: user).all.each_with_object({}) do |pick, h|
      h[pick.odd_id] = pick.team
    end
  end

  def winner!
    Game.update_scores!(id)
    return unless games_finished?

    DB.transaction do
      correct_picks(:spread)[correct_picks.keys.max].each do |user_id|
        add_winner User[user_id]
      end

      update(pot: pot + Users.count) if perfect_week?
      debt!

      # TODO: Find single winner if winners_dataset.count > 1 and betting_tier == 4
      next_week.update(betting_tier: _betting_tier, pot: _pot)
    end
  end

  def winner?
    winners_dataset.count == 1
  end

  private

  def _betting_tier
    winner? ? 1 : betting_tier + 1
  end

  def _pot
    buy_in = User.dataset.count * _betting_tier
    previous_pot = _betting_tier > 1 ? pot : 0
    buy_in + previous_pot
  end

  def debt!
    return unless winner?
    payee_id = winner.id
    amount = perfect_week?

    User.map(:id).each do |loser_id|
      Debt.create(
        amount: pot / 9,
        loser_id: loser_id,
        paid: loser_id == payee_id,
        payee_id: payee_id,
        week: self
      )
    end
  end
end
