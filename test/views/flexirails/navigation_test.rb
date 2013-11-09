require "test_helper"

class NavigationTest < ActionDispatch::IntegrationTest
  include Capybara::DSL

  test "renders per_page and current_page options" do
    visit "/static"

    assert page.has_selector?("nav.flexirails")
    assert page.has_selector?("#per_page")
    assert page.has_selector?("#current_page")
  end
end