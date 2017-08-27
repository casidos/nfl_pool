# frozen_string_literal: true

require './db'

def load_teams
  require 'yaml'

  db = DB[:teams]
  return if db.any?

  DB.transaction do
    db.insert(id: 0, name: 'Push', abbreviation: 'PUSH')
    db.insert(id: -1, name: 'Over', abbreviation: 'OVER')
    db.insert(id: -2, name: 'Under', abbreviation: 'UNDR')

    teams = YAML.load_file 'db/seed/teams.yml'
    teams.each do |abb, name|
      db.insert(abbreviation: abb.to_s, name: name)
    end
  end
end

def load_weeks(season:, betting_starts_at:, betting_ends_at:)
  db = DB[:weeks]
  return if db.where(season: season).any?

  week_later = 3600 * 24 * 7

  DB.transaction do
    (1..17).each do |i|
      db.insert(
        betting_ends_at: betting_ends_at,
        betting_starts_at: betting_starts_at,
        season: season,
        week: i
      )
      betting_ends_at += week_later
      betting_starts_at += week_later
    end
  end
end
