Sequel.migration do
  change do
    create_table :weeks do
      primary_key :id
      column :locks_at,  :timestamptz, index: true, null: false
      column :season,    :int,         index: true, null: false
      column :starts_at, :timestamptz, index: true, null: false
    end
  end
end
