# frozen_string_literal: true

require 'selenium-webdriver'

module Browser
  private

  def caps
    @_caps ||= Selenium::WebDriver::Remote::Capabilities.chrome
  end

  def browser
    @_browser ||= Selenium::WebDriver.for(
      :chrome,
      desired_capabilities: caps,
      switches: %w[--headless --no-sandbox --disable-gpu --screen-size=1200x800]
    )
  end

  def page_source
    browser.page_source
  end

  def visit_page
    browser.navigate.to url
  end
end
