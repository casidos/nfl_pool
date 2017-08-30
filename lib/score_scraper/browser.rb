# frozen_string_literal: true

require 'selenium-webdriver'

module Browser
  private

  def caps
    Selenium::WebDriver::Remote::Capabilities.chrome
  end

  def browser
    @_browser ||= Selenium::WebDriver.for(
      :chrome,
      desired_capabilities: caps,
      options: options
    )
  end

  def options
    options = Selenium::WebDriver::Chrome::Options.new
    options.binary = ENV['GOOGLE_CHROME_BIN']
    options.add_argument '--headless'
    options.add_argument '--no-sandbox'
    options.add_argument '--disable-gpu'
    options
  end

  def page_source
    browser.page_source
  end

  def visit_page
    browser.navigate.to url
  end
end
