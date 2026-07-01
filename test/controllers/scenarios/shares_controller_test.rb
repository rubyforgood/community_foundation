require "test_helper"

class Scenarios::SharesControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as users(:one)
  end

  test "create enables sharing" do
    scenario = scenarios(:one_arlington)
    post scenario_share_url(scenario)

    assert_redirected_to scenario_path(scenario)
    assert scenario.reload.shared?
  end

  test "update regenerates the token" do
    scenario = scenarios(:one_arlington)
    scenario.enable_sharing!
    token = scenario.share_token

    patch scenario_share_url(scenario)

    assert_redirected_to scenario_path(scenario)
    assert scenario.reload.shared?
    assert_not_equal token, scenario.share_token
  end

  test "destroy disables sharing" do
    scenario = scenarios(:one_arlington)
    scenario.enable_sharing!

    delete scenario_share_url(scenario)

    assert_redirected_to scenario_path(scenario)
    assert_not scenario.reload.shared?
  end

  test "requires authentication" do
    sign_out
    post scenario_share_url(scenarios(:one_arlington))
    assert_redirected_to new_session_path
  end

  test "a member cannot toggle another user's scenario" do
    sign_in_as users(:passwordless)
    post scenario_share_url(scenarios(:one_arlington))
    assert_response :not_found
    assert_not scenarios(:one_arlington).reload.shared?
  end
end
