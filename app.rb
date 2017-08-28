# frozen_string_literal: true

require_relative 'models'

require 'roda'
require 'pry'
require 'omniauth-google-oauth2'

class NFLPool < Roda
  opts[:unsupported_block_result] = :raise
  opts[:unsupported_matcher] = :raise
  opts[:verbatim_string_matcher] = true

  plugin :default_headers,
         'Content-Type' => 'text/html',
         'Content-Security-Policy' => "default-src 'self' https://oss.maxcdn.com/ https://maxcdn.bootstrapcdn.com https://ajax.googleapis.com https://lh3.googleusercontent.com",
         #'Strict-Transport-Security' => 'max-age=16070400;', # Uncomment if only allowing https:// access
         'X-Frame-Options' => 'deny',
         'X-Content-Type-Options' => 'nosniff',
         'X-XSS-Protection' => '1; mode=block'

  use Rack::Session::Cookie,
      key: 'rack.session',
      #:secure=>!TEST_MODE, # Uncomment if only allowing https:// access
      secret: File.read('.session_secret')

  use OmniAuth::Builder do
    provider :google_oauth2,
             ENV['google_client_id'],
             ENV['google_client_secret']
  end

  plugin :assets,
         css: %w[bootstrap.min.css font-awesome.min.css adminlte.min.css
                 adminlte-red.min.css nfl_pool.sass],
         js: %w[jquery.min.js jquery-ui.min.js bootstrap.min.js adminlte.min.js]
  plugin :csrf
  plugin :render, engine: :haml
  plugin :multi_route
  plugin :static, %w[/fonts /images]
  plugin :shared_vars

  compile_assets

  Unreloader.require('routes') {}

  route do |r|
    shared[:season] = 2017
    @current_user = User[session[:user_id]]

    r.assets
    r.multi_route

    r.root do
      @weeks = Week.for(shared[:season]).all
      view 'summary'
    end
  end
end
