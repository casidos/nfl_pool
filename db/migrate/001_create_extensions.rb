# frozen_string_literal: true

Sequel.migration do
  up do
    run 'CREATE EXTENSION IF NOT EXISTS "uuid-ossp";'
    run 'CREATE EXTENSION IF NOT EXISTS "citext";'
  end

  down do
    run 'DROP EXTENSION IF EXISTS "uuid-ossp";'
    run 'DROP EXTENSION IF EXISTS "citext";'
  end
end
