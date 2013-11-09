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

  test "handles first_page and last_page clicks properly" do
    Capybara.current_driver = Capybara.javascript_driver

    visit "/static"

    page.select("5", :from => "per_page")
    assert page.has_selector?(".row-5")
    refute page.has_selector?(".row-6")

    find(".pagination .last").click
    assert page.has_selector?(".row-46")
    refute page.has_selector?(".row-45")

    find(".pagination .first").click
    assert page.has_selector?(".row-5")
    refute page.has_selector?(".row-6")

    Capybara.use_default_driver
  end
end