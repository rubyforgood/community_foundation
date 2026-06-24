require "test_helper"

class Allocation::OngoingTest < ActiveSupport::TestCase
  test "dollar_amount is the percentage of ongoing giving" do
    assert_equal 1500, allocations(:greatest_need).dollar_amount
  end

  test "perpetuity_annual_amount is 5% of the dollar amount" do
    assert_equal 75, allocations(:greatest_need).perpetuity_annual_amount
  end
end
