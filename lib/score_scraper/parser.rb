require 'nokogiri'

module Parser
  def page
    @_page = ::Nokogiri::HTML browser.page_source
  end

  private

  def parse_games
    events = page.css 'div.event'
    @games = events.map do |event|
      ScoreScraper::Game.new(event)
    end
  end

  def parse_page
    parse_games
  end
end
