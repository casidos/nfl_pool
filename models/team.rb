# frozen_string_literal: true

class Team < Sequel::Model
  class << self
    %w(push over under).each do |field|
      define_method(field) { Team.first(name: field.capitalize) }
    end
  end

  def abb
    abbreviation
  end

  def logo_url
    "/images/team_logos/#{abb}.png"
  end
end
