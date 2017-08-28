# frozen_string_literal: true

class NFLPool
  route 'auth' do |r|
    r.on 'google_oauth2' do
      r.is 'callback' do
        auth_hash = request.env['omniauth.auth']
        session[:user_id] = User.with_oauth(auth_hash).id
        r.redirect '/'
      end
    end

    r.is 'sign_out' do
      session[:user_id] = nil
      r.redirect '/'
    end
  end
end
