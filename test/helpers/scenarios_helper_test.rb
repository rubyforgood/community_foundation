require "test_helper"

class ScenariosHelperTest < ActionView::TestCase
  test "one_time_amount_max is the remaining budget for a new allocation" do
    scenario = scenarios(:one_arlington)
    allocation = Allocation::OneTime.new

    assert_equal 5000, one_time_amount_max(scenario, allocation)
  end

  test "one_time_amount_max excludes the allocation's own amount when editing" do
    scenario = scenarios(:one_arlington)
    allocation = allocations(:education_grant)

    assert_equal 10000, one_time_amount_max(scenario, allocation)
  end

  test "one_time_amount_max never drops below the allocation's own amount" do
    scenario = scenarios(:one_arlington)
    scenario.update!(total_giving_amount: 4000)
    allocation = allocations(:education_grant)

    assert_equal 5000, one_time_amount_max(scenario, allocation)
  end

  test "one_time_amount_max is nil when no total giving amount is set" do
    scenario = scenarios(:two_boston)
    scenario.update!(total_giving_amount: nil)
    allocation = Allocation::OneTime.new

    assert_nil one_time_amount_max(scenario, allocation)
  end
end
