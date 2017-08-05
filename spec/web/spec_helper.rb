# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'
require_relative '../../app'
raise "test database doesn't end with test" unless
  DB.opts[:database].match?(/test\z/)

require 'capybara'
require 'capybara/dsl'
require 'rack/test'

require_relative '../minitest_helper'

Capybara.app = NFLPool.freeze

module Minitest
  class Spec
    include Rack::Test::Methods
    include Capybara::DSL
  end
end
