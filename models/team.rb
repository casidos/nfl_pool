class Team < Sequel::Model
  def abb
    abbreviation
  end

  def logo_url
    "/images/team_logos/#{abb}.png"
  end
end
