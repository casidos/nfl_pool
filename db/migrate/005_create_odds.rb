# frozen_string_literal: true

Sequel.migration do
  change do
    create_table :odds do
      primary_key :id

      foreign_key :favored_team_id, :teams, index: true
      foreign_key :game_id, :games, index: true, null: false
      foreign_key :team_id, :teams, index: true

      column :odd, :int, index: true, null: false
      column :type, :text, index: true, null: false
    end
  end
end
