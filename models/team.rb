class Team < Sequel::Model
  def abb
    abbreviation
  end
end
