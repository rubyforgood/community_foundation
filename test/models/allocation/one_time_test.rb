require "test_helper"

class Allocation::OneTimeTest < ActiveSupport::TestCase
  test "share_percentage is the allocation's share of one-time giving" do
    assert_equal 100, allocations(:education_grant).share_percentage
  end

  test "share_percentage is zero when there is no one-time giving" do
    allocation = Allocation::OneTime.new(amount: 500, scenario: scenarios(:two_boston))
    assert_equal 0, allocation.share_percentage
  end
end
