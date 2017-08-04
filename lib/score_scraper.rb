require_relative 'score_scraper/browser'
require_relative 'score_scraper/parser'
require_relative 'score_scraper/game'

class ScoreScraper
  include Browser
  include Parser

  BASE_URL = 'http://www.thescore.com/nfl/events/week/'.freeze

  attr_reader :games, :season, :week, :url

  def initialize(season = 2017, week = 1)
    @season = season
    @games = []
    new_week(week)
    true
  end

  def new_week(week)
    @week = week
    @url = BASE_URL + "#{season}-#{week}"
    visit_page
    parse_page
  end
end
