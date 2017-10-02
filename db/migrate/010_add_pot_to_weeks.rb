# frozen_string_literal: true

Sequel.migration do
  change do
    alter_table :weeks do
      add_column :pot, :int
    end
  end
end
