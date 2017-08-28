# frozen_string_literal: true

Sequel.migration do
  change do
    create_table :users do
      column :id, :uuid, default: :uuid_generate_v4.sql_function, primary_key: true

      foreign_key :team_id, :teams, index: true, null: false

      column :email, :text, index: true, null: false
      column :name, :text, null: false
      column :oauth_token, :text
      column :oauth_token_expires_at, :timestamptz
      column :profile_image_url, :text
      column :provider, :text, index: true
      column :uid, :text, index: true
    end
  end
end
