# frozen_string_literal: true

Sequel.migration do
  up do
    create_table :users_weeks do
      foreign_key :user_id, :users, type: :uuid, null: false
      foreign_key :week_id, :weeks, null: false
      primary_key [:user_id, :week_id]
    end
  end

  down do
    drop_table :users_weeks
  end
end
