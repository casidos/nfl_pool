Sequel.migration do
  change do
    create_table :teams do
      primary_key :id
      column :name,         :citext, index: true, null: false
      column :abbreviation, :citext, index: true, null: false
    end
  end
end
