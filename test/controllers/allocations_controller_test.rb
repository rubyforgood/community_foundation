require "test_helper"

class AllocationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    host! "arlington.localhost"
    sign_in_as users(:one)
    @scenario = scenarios(:one_arlington)
  end

  test "creates an ongoing allocation" do
    assert_difference -> { @scenario.allocations.count }, 1 do
      post scenario_allocations_url(@scenario), params: {
        allocation: { type: "Allocation::Ongoing", option: "Population: Youth", percentage: 25 }
      }
    end
    assert_redirected_to scenario_path(@scenario)
  end

  test "creates a one time allocation" do
    assert_difference -> { @scenario.allocations.count }, 1 do
      post scenario_allocations_url(@scenario), params: {
        allocation: { type: "Allocation::OneTime", option: "Specific org", amount: 1000 }
      }
    end
    assert_redirected_to scenario_path(@scenario)
  end

  test "rejects a one_time allocation that exceeds the total giving amount" do
    # scenario total is 10000 and education_grant fixture already allocates 5000.
    assert_no_difference -> { @scenario.allocations.count } do
      post scenario_allocations_url(@scenario), params: {
        allocation: { type: "Allocation::OneTime", option: "Too big", amount: 6000 }
      }
    end
    assert_redirected_to scenario_path(@scenario)
    assert flash[:alert].present?
  end

  test "destroys an allocation" do
    assert_difference -> { @scenario.allocations.count }, -1 do
      delete scenario_allocation_url(@scenario, allocations(:greatest_need))
    end
    assert_redirected_to scenario_path(@scenario)
  end

  test "cannot add an allocation to a scenario you do not own" do
    assert_no_difference -> { Allocation.count } do
      post scenario_allocations_url(scenarios(:two_boston)), params: {
        allocation: { type: "Allocation::Ongoing", option: "X", percentage: 10 }
      }
    end
    assert_response :not_found
  end
end
