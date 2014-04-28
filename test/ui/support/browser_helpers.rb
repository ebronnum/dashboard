module BrowserHelpers
  def element_has_text(selector, expectedText)
    expectedText.gsub!('\"', '"')
    text = @browser.execute_script("return $(\"#{selector}\").text();");
    text.should eq expectedText
  end

  def wait
    Selenium::WebDriver::Wait.new(:timeout => 60 * 2)
  end

  def short_wait
    Selenium::WebDriver::Wait.new(:timeout => 5)
  end
end

World(BrowserHelpers)
