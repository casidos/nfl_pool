# frozen_string_literal: true

Sequel.migration do
  change do
    alter_table :weeks do
      add_column :betting_tier, :int
    end
  end
end
