# frozen_string_literal: true

Sequel.migration do
  change do
    create_table :debts do
      column :id, :uuid, default: :uuid_generate_v4.sql_function, primary_key: true

      foreign_key :loser_id, :users, index: true, null: false, type: :uuid
      foreign_key :payee_id, :users, index: true, null: false, type: :uuid
      foreign_key :week_id,  :weeks, index: true, null: false

      column :amount, :int, index: true, null: false
      column :paid,   :bool, default: false, index: true, null: false
    end
  end
end
