require "application_system_test_case"

class HomeTest < ApplicationSystemTestCase
  test "the apex landing lists the community foundations" do
    visit "/"

    assert_selector "h1", text: "Community Foundations"
    assert_link organizations(:arlington).name
  end
end
