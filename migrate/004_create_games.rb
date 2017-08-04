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
      column :spread,          'numeric(3, 1)'
    end
  end
end
