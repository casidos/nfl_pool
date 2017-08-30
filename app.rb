# frozen_string_literal: true

require_relative 'models'

require 'roda'
require 'pry'
require 'omniauth-google-oauth2'

root = Pathname.new(File.expand_path('..', __FILE__)).freeze
Dir[root.join('lib', '**', '*.rb')].each { |f| require f }

class NFLPool < Roda
  opts[:unsupported_block_result] = :raise
  opts[:unsupported_matcher] = :raise
  opts[:verbatim_string_matcher] = true

  headers_opts = {
    'Content-Type' => 'text/html',
    'Content-Security-Policy' => "default-src 'self' https://oss.maxcdn.com/ https://maxcdn.bootstrapcdn.com https://ajax.googleapis.com https://lh3.googleusercontent.com",
    'X-Frame-Options' => 'deny',
    'X-Content-Type-Options' => 'nosniff',
    'X-XSS-Protection' => '1; mode=block'
  }
  cookie_opts = {
    key: 'rack.session',
    secret: ENV['SESSION_SECRET']
  }

  if ENV['RACK_ENV'] == 'production'
    headers_opts['Strict-Transport-Security'] = 'max-age=16070400;'
    #cookie_opts[:secure] = !TEST_MODE
  end

  plugin :default_headers, headers_opts
  use Rack::Session::Cookie, cookie_opts

  plugin :assets,
         css: %w[bootstrap.min.css font-awesome.min.css adminlte.min.css
                 adminlte-red.min.css nfl_pool.sass],
         js: %w[jquery.min.js jquery-ui.min.js bootstrap.min.js adminlte.min.js nfl_pool.js]
  plugin :authentication
  plugin :csrf
  plugin :render, engine: :haml
  plugin :multi_route
  plugin :static, %w[/fonts /images]
  plugin :shared_vars

  compile_assets

  Unreloader.require('routes') {}

  route do |r|
    r.redirect r.url.tr('http', 'https') if ENV['RACK_ENV'] == 'production' && r.scheme == 'http'

    r.assets
    r.is('sign_in') { view 'sign_in' }
    r.authenticate! unless r.path.include?('auth')

    shared[:season] = 2017
    @current_week = Week.current
    @current_week_path = "/picks/#{@current_week.week}"

    r.multi_route

    r.root do
      @weeks = Week.for(shared[:season]).all
      view 'summary'
    end
  end
end
