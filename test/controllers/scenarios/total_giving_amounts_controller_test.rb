require "test_helper"

class Scenarios::TotalGivingAmountsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as users(:one)
    @scenario = scenarios(:one_arlington)
  end

  test "show renders the inline total giving amount frame" do
    get scenario_total_giving_amount_url(@scenario)
    assert_response :success
    assert_select "turbo-frame##{dom_id(@scenario, :total_giving_amount)}"
  end

  test "edit renders the inline total giving amount form" do
    get edit_scenario_total_giving_amount_url(@scenario)
    assert_response :success
    assert_select "turbo-frame##{dom_id(@scenario, :total_giving_amount)} form input[name=?]", "scenario[total_giving_amount]"
  end

  test "update changes the total giving amount" do
    patch scenario_total_giving_amount_url(@scenario), params: { scenario: { total_giving_amount: 5000 } }
    assert_response :success
    assert_equal 5000, @scenario.reload.total_giving_amount
  end

  test "cannot edit a scenario owned by another user or org" do
    get edit_scenario_total_giving_amount_url(scenarios(:two_boston))
    assert_response :not_found
  end

  test "admin can edit another user's scenario total in the same org" do
    sign_in_as users(:admin)
    get edit_scenario_total_giving_amount_url(@scenario)
    assert_response :success

    patch scenario_total_giving_amount_url(@scenario), params: { scenario: { total_giving_amount: 7500 } }
    assert_response :success
    assert_equal 7500, @scenario.reload.total_giving_amount
  end

  test "plain member cannot edit another user's scenario total in the same org" do
    sign_in_as users(:passwordless)
    get edit_scenario_total_giving_amount_url(@scenario)
    assert_response :not_found
  end
end
