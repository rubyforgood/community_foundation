require "test_helper"

class ScenariosControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as users(:one)
  end

  test "index lists the donor's scenarios" do
    get scenarios_url
    assert_response :success
    assert_select "h1", "Explore options"
    assert_match scenarios(:one_arlington).name, response.body
  end

  test "requires authentication" do
    sign_out
    get scenarios_url
    assert_redirected_to new_session_path
  end

  test "new renders the scenario form" do
    get new_scenario_url
    assert_response :success
    assert_select "form"
  end

  test "create makes a named scenario for the current donor and org" do
    assert_difference -> { users(:one).scenarios.count }, 1 do
      post scenarios_url, params: { scenario: { name: "Education focus" } }
    end
    scenario = users(:one).scenarios.order(:created_at).last
    assert_equal "Education focus", scenario.name
    assert_equal organizations(:arlington), scenario.organization
    assert_redirected_to scenario_path(scenario)
  end

  test "create re-renders the form when name is blank" do
    assert_no_difference -> { Scenario.count } do
      post scenarios_url, params: { scenario: { name: "" } }
    end
    assert_response :unprocessable_entity
  end

  test "show renders an owned scenario" do
    get scenario_url(scenarios(:one_arlington))
    assert_response :success
  end

  test "update changes total giving amount" do
    patch scenario_url(scenarios(:one_arlington)), params: { scenario: { total_giving_amount: 2500 } }
    assert_equal 2500, scenarios(:one_arlington).reload.total_giving_amount
  end

  test "destroy removes the scenario" do
    assert_difference -> { Scenario.count }, -1 do
      delete scenario_url(scenarios(:one_arlington))
    end
    assert_redirected_to scenarios_path
  end

  test "cannot access a scenario owned by another user or org" do
    get scenario_url(scenarios(:two_boston))
    assert_response :not_found
  end

  test "admin can view another user's scenario in the same org" do
    sign_in_as users(:admin)
    get scenario_url(scenarios(:one_arlington))
    assert_response :success
    assert_select "a[href=?]", admin_scenarios_path
    assert_match "as an admin", response.body
  end

  test "admin can update another user's scenario" do
    sign_in_as users(:admin)
    patch scenario_url(scenarios(:one_arlington)), params: { scenario: { total_giving_amount: 999 } }
    assert_equal 999, scenarios(:one_arlington).reload.total_giving_amount
  end

  test "admin destroy of another user's scenario returns to the admin dashboard" do
    sign_in_as users(:admin)
    assert_difference -> { Scenario.count }, -1 do
      delete scenario_url(scenarios(:one_arlington))
    end
    assert_redirected_to admin_scenarios_path
  end

  test "admin still cannot reach a scenario in another org" do
    sign_in_as users(:admin)
    get scenario_url(scenarios(:two_boston))
    assert_response :not_found
  end

  test "plain member cannot reach another user's scenario in the same org" do
    sign_in_as users(:passwordless)
    get scenario_url(scenarios(:one_arlington))
    assert_response :not_found
  end

  test "super admin cannot change another user's scenario" do
    sign_in_as users(:super_admin)
    patch scenario_url(scenarios(:one_arlington)), params: { scenario: { total_giving_amount: 1 } }
    assert_response :not_found
    assert_equal 10000, scenarios(:one_arlington).reload.total_giving_amount
  end
end
