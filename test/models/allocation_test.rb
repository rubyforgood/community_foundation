require "test_helper"

class AllocationTest < ActiveSupport::TestCase
  setup { @scenario = scenarios(:one_arlington) }

  test "requires an option" do
    allocation = @scenario.ongoing_allocations.new(percentage: 10, option: "")
    assert_not allocation.valid?
    assert_includes allocation.errors[:option], "can't be blank"
  end

  test "ongoing requires a percentage between 0 and 100" do
    assert_not @scenario.ongoing_allocations.new(option: "X").valid?
    assert_not @scenario.ongoing_allocations.new(option: "X", percentage: 150).valid?
    assert @scenario.ongoing_allocations.new(option: "X", percentage: 25).valid?
  end

  test "one_time requires a positive amount" do
    assert_not @scenario.one_time_allocations.new(option: "X").valid?
    assert_not @scenario.one_time_allocations.new(option: "X", amount: 0).valid?
    assert @scenario.one_time_allocations.new(option: "X", amount: 100).valid?
  end

  test "ongoing does not require an amount" do
    assert @scenario.ongoing_allocations.new(option: "X", percentage: 10).valid?
  end

  test "one_time allocations cannot exceed the total giving amount" do
    # scenario total is 10000 and education_grant fixture already allocates 5000.
    assert_not @scenario.one_time_allocations.new(option: "Too much", amount: 5001).valid?
    assert @scenario.one_time_allocations.new(option: "Just fits", amount: 5000).valid?
  end

  test "kind predicates reflect the subclass" do
    assert allocations(:greatest_need).ongoing?
    assert_not allocations(:greatest_need).one_time?
    assert allocations(:education_grant).one_time?
  end
end
