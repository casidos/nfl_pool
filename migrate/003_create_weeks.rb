Sequel.migration do
  change do
    create_table :weeks do
      primary_key :id
      column :betting_ends_at,   :timestamptz, index: true, null: false
      column :betting_starts_at, :timestamptz, index: true, null: false
      column :season,            :int,         index: true, null: false
      column :week,              :int,         index: true, null: false
    end
  end
end
