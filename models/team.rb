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

  def icon_name
    case name
    when 'Over'
      'arrow-circle-up'
    when 'Under'
      'arrow-circle-down'
    when 'Push'
      'arrows-h'
    end
  end

  def logo_url
    "/images/team_logos/#{abb}.png"
  end
end
