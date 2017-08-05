# frozen_string_literal: true

Sequel.migration do
  change do
    create_table :games do
      primary_key :id

      foreign_key :away_team_id,       :teams, index: true, null: false
      foreign_key :game_winner_id,     :teams, index: true
      foreign_key :home_team_id,       :teams, index: true, null: false
      foreign_key :spread_favorite_id, :teams, index: true
      foreign_key :spread_winner_id,   :teams, index: true
      foreign_key :week_id,            :weeks, index: true, null: false

      column :away_team_score, :int
      column :final,           :bool, default: false, index: true, null: false
      column :followed,        :bool, default: false, index: true, null: false
      column :home_team_score, :int
      column :over_covered,    :bool
      column :over_under,      'numeric(4, 1)'
      column :quarter_time,    :text
      column :remote_id,       :text
      column :spread,          'numeric(3, 1)'
      column :starts_at,       :timestamptz, index: true, null: false
      column :status,          :text, index: true, null: false
    end
  end
end
