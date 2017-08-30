# frozen_string_literal: true

Sequel.migration do
  change do
    create_table :picks do
      primary_key :id

      foreign_key :odd_id, :odds, index: true, null: false
      foreign_key :team_id, :teams, index: true, null: false
      foreign_key :user_id, :users, index: true, null: false, type: :uuid

      column :won, :boolean, index: true
    end
  end
end
