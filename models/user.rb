# frozen_string_literal: true

class User < Sequel::Model
  class << self
    def with_oauth(auth)
      user = first(email: auth.info.email) || new_user(auth)
      user.oauth_token = auth.credentials.token
      user.oauth_token_expires_at = Time.at(
        auth.credentials.expires_at
      ) if auth.credentials.expires
      user.save
    end

    private

    # TODO: remove team and let them select their own
    def new_user(auth)
      new(
        email: auth.info.email,
        name: auth.info.first_name,
        profile_image_url: auth.info.image,
        provider: auth.provider,
        team_id: 26,
        uid: auth.uid
      )
    end
  end

  many_to_one :team

  def image_url
    profile_image_url || team.logo_url
  end
end
