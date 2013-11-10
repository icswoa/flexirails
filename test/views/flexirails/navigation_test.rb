require "test_helper"

class NavigationTest < ActionDispatch::IntegrationTest
  include Capybara::DSL

  test "renders per_page and current_page options" do
    visit "/static"

    assert page.has_selector?("nav.flexirails")
    assert page.has_selector?("#per_page")
    assert page.has_selector?("#current_page")
  end

  test "handles next_page and prev_page clicks properly" do
    visit "/static"

    assert page.has_selector?(".row-25")
    refute page.has_selector?(".row-50")

    find(".pagination .next").click

    refute page.has_selector?(".row-25")
    assert page.has_selector?(".row-50")

    find(".pagination .prev").click

    assert page.has_selector?(".row-25")
    refute page.has_selector?(".row-50")
  end
end