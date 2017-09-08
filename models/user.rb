# frozen_string_literal: true

# == Schema Info
#
# email                   string    indexed      not null
# id                      uuid      primary_key  not null, uuid_v4
# name                    string                 not null
# oauth_token             string
# oauth_token_expires_at  datetime
# profile_image_url       string
# provider                string    indexed
# team_id                 integer   indexed      not null
# uid                     string    indexed
#

class User < Sequel::Model
  class UnauthorizedUserError < StandardError
  end

  class << self
    def with_oauth(auth)
      user = first(email: auth.info.email)
      return fail(User::UnauthorizedUserError) unless user

      user.set(
        profile_image_url: auth.info.image,
        provider: auth.provider,
        uid: auth.uid
      ) unless user.uid

      user.oauth_token = auth.credentials.token
      user.oauth_token_expires_at = Time.at(
        auth.credentials.expires_at
      ) if auth.credentials.expires
      user.save
    end
  end

  many_to_one :team

  one_to_many :correct_picks, class: :Pick, conditions: { won: true}
  one_to_many :picks

  def pretty_correct_picks
    c = correct_picks_dataset.count
    t =  picks_dataset.exclude(won: nil).count
    p = c.to_f / t.to_f
    p = p.nan? ? 0 : p * 100
    "#{c} (#{'%.1f' % p}%)"
  end

  def image_url
    profile_image_url || team.logo_url
  end
end
