require "test_helper"

class Public::ScenariosControllerTest < ActionDispatch::IntegrationTest
  test "renders a shared scenario without authentication" do
    scenario = scenarios(:one_arlington)
    scenario.enable_sharing!

    get public_scenario_url(scenario.share_token)

    assert_response :success
    assert_match scenario.name, response.body
    assert_match scenario.user.display_name, response.body
    assert_match "Allocation summary", response.body
  end

  test "does not render edit controls" do
    scenario = scenarios(:one_arlington)
    scenario.enable_sharing!

    get public_scenario_url(scenario.share_token)

    assert_no_match "Add allocation", response.body
    assert_select "input[type=range]", false
  end

  test "returns not found for a scenario that is not shared" do
    get public_scenario_url("nope")
    assert_response :not_found
  end

  test "returns not found after sharing is disabled" do
    scenario = scenarios(:one_arlington)
    scenario.enable_sharing!
    token = scenario.share_token
    scenario.disable_sharing!

    get public_scenario_url(token)
    assert_response :not_found
  end

  test "cannot reach a shared scenario from another organization" do
    boston_scenario = scenarios(:two_boston)
    boston_scenario.enable_sharing!

    get public_scenario_url(boston_scenario.share_token)
    assert_response :not_found
  end
end
