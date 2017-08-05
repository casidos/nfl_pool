require_relative 'db'

def load_teams
  db = DB[:teams]
  return if db.any?

  db.insert(id: 0, name: 'Push', abbreviation: 'PUSH')

  {
    ARI: 'Arizona',
    ATL: 'Atlanta',
    BAL: 'Baltimore',
    BUF: 'Buffalo',
    CAR: 'Carolina',
    CHI: 'Chicago',
    CIN: 'Cincinnati',
    CLE: 'Cleveland',
    DAL: 'Dallas',
    DEN: 'Denver',
    DET: 'Detroit',
    GB:  'Green Bay',
    HOU: 'Houston',
    IND: 'Indianapolis',
    JAX: 'Jacksonville',
    KC:  'Kansas City',
    LAC: 'LA Chargers',
    LAR: 'LA Rams',
    MIA: 'Miami',
    MIN: 'Minnesota',
    NYG: 'NY Giants',
    NYJ: 'NY Jets',
    NE:  'New England',
    NO:  'New Orleans',
    OAK: 'Oakland',
    PHI: 'Philadelphia',
    PIT: 'Pittsburgh',
    SF:  'San Francisco',
    SEA: 'Seattle',
    TB:  'Tampa Bay',
    TEN: 'Tennessee',
    WAS: 'Washington',
  }.each do |abb, name|
    db.insert(abbreviation: abb.to_s, name: name)
  end
end

def load_weeks(season:, betting_starts_at:, betting_ends_at:)
  db = DB[:weeks]
  return if db.where(season: season).any?

  week_later = 3600 * 24 * 7

  (1..17).each do |i|
    db.insert(
      betting_ends_at: betting_ends_at,
      betting_starts_at: betting_starts_at,
      season: season,
      week: i
    )
    betting_ends_at += week_later
    betting_starts_at += week_later
  end
end
