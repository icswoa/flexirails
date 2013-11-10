require "test_helper"

class NavigationTest < ActionDispatch::IntegrationTest
  include Capybara::DSL

  setup do
    Capybara.current_driver = Capybara.javascript_driver
  end

  test "handles first_page and last_page clicks properly" do
    visit "/static"

    select("5", :from => "per_page")
    assert page.has_selector?(".row-5")
    refute page.has_selector?(".row-6")

    find(".pagination .last").click
    assert page.has_selector?(".row-46")
    refute page.has_selector?(".row-45")

    find(".pagination .first").click
    assert page.has_selector?(".row-5")
    refute page.has_selector?(".row-6")
  end

  test "handles current_page properly on per_page changes" do
    visit "/static"

    select("5", :from => "per_page")
    find(".pagination .last").click
    assert_equal "10", find("#current_page").value

    select("50", :from => "per_page")
    assert_equal "1", find("#current_page").value
  end
end