require "test_helper"

class AllocationTest < ActiveSupport::TestCase
  setup { @scenario = scenarios(:one_arlington) }

  test "requires a category or an option" do
    neither = @scenario.ongoing_allocations.new(percentage: 10)
    assert_not neither.valid?
    assert_includes neither.errors[:base], "Choose a category or enter a custom option"

    with_option = @scenario.ongoing_allocations.new(percentage: 10, option: "Custom")
    assert with_option.valid?

    with_category = @scenario.ongoing_allocations.new(percentage: 10, allocation_category: allocation_categories(:population_youth))
    assert with_category.valid?
  end

  test "display_label prefers the category name, falling back to the option" do
    assert_equal "Education", allocations(:education_grant).display_label
    assert_equal "Greatest Community Need", allocations(:greatest_need).display_label
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

  test "ongoing dollar_amount is its percentage of the scenario's ongoing giving" do
    # scenario ongoing giving is 10000 total - 5000 one-time = 5000; greatest_need is 30%.
    assert_equal 1500, allocations(:greatest_need).dollar_amount
  end

  test "preference_categories can be assigned and destroying the allocation removes the join rows" do
    allocation = allocations(:greatest_need)
    youth = allocation_categories(:population_youth)
    education = allocation_categories(:program_education)
    allocation.update!(preference_category_ids: [ youth.id, education.id ])
    assert_equal [ youth, education ].sort_by(&:id), allocation.preference_categories.sort_by(&:id)

    assert_difference -> { AllocationPreference.count }, -2 do
      allocation.destroy
    end
  end

  test "kind predicates reflect the subclass" do
    assert allocations(:greatest_need).ongoing?
    assert_not allocations(:greatest_need).one_time?
    assert allocations(:education_grant).one_time?
  end
end
