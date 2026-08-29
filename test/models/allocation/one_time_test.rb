require "test_helper"

class Allocation::OneTimeTest < ActiveSupport::TestCase
  test "share_percentage is the allocation's share of one-time giving" do
    assert_equal 100, allocations(:education_grant).share_percentage
  end

  test "share_percentage is zero when there is no one-time giving" do
    allocation = Allocation::OneTime.new(amount: 500, scenario: scenarios(:two_boston))
    assert_equal 0, allocation.share_percentage
  end

  test "max_amount is the remaining budget for a new allocation" do
    scenario = scenarios(:one_arlington)
    allocation = Allocation::OneTime.new

    assert_equal 5000, allocation.max_amount(scenario)
  end

  test "max_amount excludes the allocation's own amount when editing" do
    scenario = scenarios(:one_arlington)
    allocation = allocations(:education_grant)

    assert_equal 10000, allocation.max_amount(scenario)
  end

  test "max_amount never drops below the allocation's own amount" do
    scenario = scenarios(:one_arlington)
    scenario.update!(total_giving_amount: 4000)
    allocation = allocations(:education_grant)

    assert_equal 5000, allocation.max_amount(scenario)
  end

  test "max_amount is nil when no total giving amount is set" do
    scenario = scenarios(:two_boston)
    scenario.update!(total_giving_amount: nil)
    allocation = Allocation::OneTime.new

    assert_nil allocation.max_amount(scenario)
  end
end
