# frozen_string_literal: true

# Migrate

migrate = lambda do |env, version|
  ENV['RACK_ENV'] = env
  require_relative 'db'
  require 'logger'
  Sequel.extension :migration
  DB.loggers << Logger.new($stdout)
  Sequel::Migrator.apply(DB, 'db/migrate', version)
  Rake::Task['annotate'].invoke
end

desc 'Migrate test database to latest version'
task :test_up do
  migrate.call('test', nil)
end

desc 'Migrate test database all the way down'
task :test_down do
  migrate.call('test', 0)
end

desc 'Migrate test database all the way down and then back up'
task :test_bounce do
  migrate.call('test', 0)
  Sequel::Migrator.apply(DB, 'db/migrate')
  Rake::Task['test_seed'].invoke
end

desc 'Migrate development database to latest version'
task :dev_up do
  migrate.call('development', nil)
end

desc 'Migrate development database to all the way down'
task :dev_down do
  migrate.call('development', 0)
end

desc 'Migrate development database all the way down and then back up'
task :dev_bounce do
  migrate.call('development', 0)
  Sequel::Migrator.apply(DB, 'db/migrate')
  Rake::Task['dev_seed'].invoke
end

desc 'Migrate production database to latest version'
task :prod_up do
  migrate.call('production', nil)
end

seed = proc do |env|
  ENV['RACK_ENV'] = env
  require './db/seed'
  load_teams
  load_weeks(
    season: 2017,
    betting_starts_at: Time.new(2017, 9, 5, 0, 0, 0, '-07:00'),
    betting_ends_at: Time.new(2017, 9, 7, 16, 30, 0, '-07:00')
  )
end

desc 'Seed test database'
task :test_seed do
  seed.call 'test'
end

desc 'Seed development database'
task :dev_seed do
  seed.call 'development'
end

desc 'Seed production database'
task :prod_seed do
  seed.call 'production'
end

# Shell

irb = proc do |env|
  ENV['RACK_ENV'] = env
  trap('INT', 'IGNORE')
  dir, base = File.split(FileUtils::RUBY)
  cmd = if base.sub!(/\Aruby/, 'irb')
          File.join(dir, base)
        else
          "#{FileUtils::RUBY} -S irb"
        end
  sh "#{cmd} -r ./models"
end

desc 'Open irb shell in test mode'
task :test_irb do
  irb.call('test')
end

desc 'Open irb shell in development mode'
task :dev_irb do
  irb.call('development')
end

desc 'Open irb shell in production mode'
task :prod_irb do
  irb.call('production')
end

# Specs

spec = proc do |pattern|
  sh "#{FileUtils::RUBY} -e 'ARGV.each{|f| require f}' #{pattern}"
end

desc 'Run all specs'
task test: %i[model_spec web_spec]

desc 'Run model specs'
task :model_spec do
  spec.call('./spec/model/*_spec.rb')
end

desc 'Run web specs'
task :web_spec do
  spec.call('./spec/web/*_spec.rb')
end

desc 'Annotate all model files'
task :annotate do
  require_relative 'lib/sequel_annotator'
  puts SequelAnnotator.()
end

desc 'Update scores and determine winner!'
task :week_winner do
  # Check: Sun, Mon, Thurs
  t = Time.now
  next unless [0, 1, 4].include?(t.wday)

  require_relative 'models'
  week = Week.current
  next if week.games_dataset.began.unfinished.empty?

  week.winner!
end

task default: :dev_irb
task up: :dev_up
task down: :dev_down
task bounce: :dev_bounce
task irb: :dev_irb
