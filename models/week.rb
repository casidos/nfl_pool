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

  one_to_many :games, order: :starts_at
end
