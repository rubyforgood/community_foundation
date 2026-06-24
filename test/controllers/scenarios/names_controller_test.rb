require "test_helper"

class Scenarios::NamesControllerTest < ActionDispatch::IntegrationTest
  setup do
    host! "arlington.localhost"
    sign_in_as users(:one)
    @scenario = scenarios(:one_arlington)
  end

  test "show renders the inline name frame" do
    get scenario_name_url(@scenario)
    assert_response :success
    assert_select "turbo-frame##{dom_id(@scenario, :name)}"
  end

  test "edit renders the inline name form" do
    get edit_scenario_name_url(@scenario)
    assert_response :success
    assert_select "turbo-frame##{dom_id(@scenario, :name)} form input[name=?]", "scenario[name]"
  end

  test "update changes the name" do
    patch scenario_name_url(@scenario), params: { scenario: { name: "Renamed scenario" } }
    assert_response :success
    assert_equal "Renamed scenario", @scenario.reload.name
  end

  test "update re-renders the form when name is blank" do
    patch scenario_name_url(@scenario), params: { scenario: { name: "" } }
    assert_response :unprocessable_entity
    assert_select "form input[name=?]", "scenario[name]"
  end

  test "cannot edit a scenario owned by another user or org" do
    get edit_scenario_name_url(scenarios(:two_boston))
    assert_response :not_found
  end

  test "admin can edit another user's scenario name in the same org" do
    sign_in_as users(:admin)
    get edit_scenario_name_url(@scenario)
    assert_response :success

    patch scenario_name_url(@scenario), params: { scenario: { name: "Admin renamed" } }
    assert_response :success
    assert_equal "Admin renamed", @scenario.reload.name
  end

  test "plain member cannot edit another user's scenario name in the same org" do
    sign_in_as users(:passwordless)
    get edit_scenario_name_url(@scenario)
    assert_response :not_found
  end
end
