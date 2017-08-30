# frozen_string_literal: true

require_relative '.env.rb'

require 'sequel'

# Delete DATABASE_URL from the environment, so it isn't accidently
# passed to subprocesses.  DATABASE_URL may contain passwords.
DB = Sequel.connect(ENV.delete('DATABASE_URL'))
DB.extension :freeze_datasets

Sequel.extension :core_extensions
Sequel::Model.plugin :many_through_many
Sequel::Model.plugin :update_or_create
Sequel::Model.plugin :uuid
