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

  test "creates an allocation targeting a category" do
    category = allocation_categories(:population_youth)
    assert_difference -> { @scenario.allocations.count }, 1 do
      post scenario_allocations_url(@scenario), params: {
        allocation: { type: "Allocation::Ongoing", allocation_category_id: category.id, option: "", percentage: 25 }
      }
    end
    assert_redirected_to scenario_path(@scenario)
    assert_equal category, @scenario.allocations.order(:created_at).last.allocation_category
  end

  test "creates an allocation with additional preferences" do
    youth = allocation_categories(:population_youth)
    education = allocation_categories(:program_education)
    post scenario_allocations_url(@scenario), params: {
      allocation: { type: "Allocation::Ongoing", option: "Mixed", percentage: 25,
                    preference_category_ids: [ "", youth.id, education.id ] }
    }
    assert_redirected_to scenario_path(@scenario)
    allocation = @scenario.allocations.order(:created_at).last
    assert_equal [ youth, education ].sort_by(&:id), allocation.preference_categories.sort_by(&:id)
  end

  test "updating with an empty preference list clears existing preferences" do
    allocation = allocations(:greatest_need)
    allocation.update!(preference_category_ids: [ allocation_categories(:population_youth).id ])

    patch scenario_allocation_url(@scenario, allocation), params: {
      allocation: { preference_category_ids: [ "" ] }
    }
    assert_redirected_to scenario_path(@scenario)
    assert_empty allocation.reload.preference_categories
  end

  test "renders the always-present Greatest Community Need card" do
    # one_arlington already has the greatest_need fixture allocation.
    get scenario_url(@scenario)
    assert_response :success
    assert_match Allocation::GreatestCommunityNeed::DESCRIPTION, response.body
  end

  test "rejects a duplicate Greatest Community Need allocation" do
    # one_arlington already has the greatest_need fixture allocation.
    assert_no_difference -> { @scenario.allocations.count } do
      post scenario_allocations_url(@scenario), params: {
        allocation: { type: "Allocation::GreatestCommunityNeed", percentage: 20 }
      }
    end
    assert_redirected_to scenario_path(@scenario)
    assert flash[:alert].present?
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

  test "updates an ongoing allocation" do
    allocation = allocations(:greatest_need)
    patch scenario_allocation_url(@scenario, allocation), params: {
      allocation: { option: "Greatest Need (revised)", percentage: 55, note: "Updated" }
    }
    assert_redirected_to scenario_path(@scenario)
    allocation.reload
    assert_equal "Greatest Need (revised)", allocation.option
    assert_equal 55, allocation.percentage
    assert_equal "Updated", allocation.note
  end

  test "updates a one time allocation" do
    allocation = allocations(:education_grant)
    patch scenario_allocation_url(@scenario, allocation), params: {
      allocation: { amount: 4000 }
    }
    assert_redirected_to scenario_path(@scenario)
    assert_equal 4000, allocation.reload.amount
  end

  test "rejects an update that exceeds the total giving amount" do
    # scenario total is 10000; education_grant is the only one_time allocation.
    allocation = allocations(:education_grant)
    patch scenario_allocation_url(@scenario, allocation), params: {
      allocation: { amount: 11000 }
    }
    assert_redirected_to scenario_path(@scenario)
    assert flash[:alert].present?
    assert_equal 5000, allocation.reload.amount
  end

  test "cannot update an allocation on a scenario you do not own" do
    # set_scenario scopes to the current user, so the unowned scenario 404s
    # before the allocation is ever looked up.
    patch scenario_allocation_url(scenarios(:two_boston), allocations(:greatest_need)), params: {
      allocation: { option: "Hacked" }
    }
    assert_response :not_found
  end

  test "destroys an allocation" do
    assert_difference -> { @scenario.allocations.count }, -1 do
      delete scenario_allocation_url(@scenario, allocations(:education_grant))
    end
    assert_redirected_to scenario_path(@scenario)
  end

  test "cannot delete the Greatest Community Need allocation" do
    assert_no_difference -> { @scenario.allocations.count } do
      delete scenario_allocation_url(@scenario, allocations(:greatest_need))
    end
    assert_redirected_to scenario_path(@scenario)
    assert flash[:alert].present?
  end

  test "cannot add an allocation to a scenario you do not own" do
    assert_no_difference -> { Allocation.count } do
      post scenario_allocations_url(scenarios(:two_boston)), params: {
        allocation: { type: "Allocation::Ongoing", option: "X", percentage: 10 }
      }
    end
    assert_response :not_found
  end

  test "admin can add an allocation to another user's scenario in the same org" do
    sign_in_as users(:admin)
    assert_difference -> { @scenario.allocations.count }, 1 do
      post scenario_allocations_url(@scenario), params: {
        allocation: { type: "Allocation::Ongoing", option: "Population: Youth", percentage: 25 }
      }
    end
    assert_redirected_to scenario_path(@scenario)
  end

  test "admin can destroy an allocation on another user's scenario in the same org" do
    sign_in_as users(:admin)
    assert_difference -> { @scenario.allocations.count }, -1 do
      delete scenario_allocation_url(@scenario, allocations(:education_grant))
    end
    assert_redirected_to scenario_path(@scenario)
  end

  test "plain member cannot add an allocation to another user's scenario in the same org" do
    sign_in_as users(:passwordless)
    assert_no_difference -> { Allocation.count } do
      post scenario_allocations_url(@scenario), params: {
        allocation: { type: "Allocation::Ongoing", option: "X", percentage: 10 }
      }
    end
    assert_response :not_found
  end
end
