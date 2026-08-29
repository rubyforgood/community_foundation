require "test_helper"

class Allocation::OngoingTest < ActiveSupport::TestCase
  test "dollar_amount is the percentage of ongoing giving in cents" do
    assert_equal 150000, allocations(:greatest_need).dollar_amount
  end

  test "perpetuity_annual_amount is 5% of the dollar amount in cents" do
    assert_equal 7500, allocations(:greatest_need).perpetuity_annual_amount
  end

  test "retains cents when percentage math produces a sub-dollar amount" do
    scenario = Scenario.new(organization: organizations(:arlington), user: users(:one), name: "Cents plan")
    scenario.total_giving_amount = 100
    scenario.save!
    scenario.one_time_allocations.delete_all

    allocation = scenario.ongoing_allocations.create!(option: "X", percentage: 33)

    assert_equal 3300, allocation.dollar_amount
    assert_equal 165, allocation.perpetuity_annual_amount
  end
end
