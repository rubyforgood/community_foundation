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

  # These messages render raw under the field (scenarios/_field_errors), with no
  # attribute name in front of them, so each has to read as a whole sentence and
  # there can only be one of them per problem.
  test "every one_time amount error is a single full sentence" do
    {
      nil => "Enter an amount.",
      0 => "Enter a whole dollar amount greater than $0.",
      "1.5" => "Enter a whole dollar amount greater than $0.",
      "abc" => "Enter a whole dollar amount greater than $0.",
      5001 => "You have $5,000 left to allocate."
    }.each do |amount, message|
      allocation = @scenario.one_time_allocations.new(option: "X", amount: amount)
      allocation.valid?
      assert_equal [ message ], allocation.errors[:amount], "for amount #{amount.inspect}"
    end
  end

  test "every ongoing percentage error is a single full sentence" do
    {
      nil => "Choose a percentage.",
      -5 => "Enter a percentage between 0 and 100.",
      200 => "Enter a percentage between 0 and 100.",
      "1.5" => "Enter a percentage between 0 and 100.",
      71 => "You have 70% left to allocate."
    }.each do |percentage, message|
      allocation = @scenario.ongoing_allocations.new(option: "X", percentage: percentage)
      allocation.valid?
      assert_equal [ message ], allocation.errors[:percentage], "for percentage #{percentage.inspect}"
    end
  end

  test "ongoing allocations cannot push the scenario's total over 100%" do
    # greatest_need fixture already allocates 30% in this scenario.
    assert_not @scenario.ongoing_allocations.new(option: "Too much", percentage: 71).valid?
    assert @scenario.ongoing_allocations.new(option: "Just fits", percentage: 70).valid?
  end

  test "updating an ongoing allocation excludes its own prior percentage from the total" do
    allocation = allocations(:greatest_need)
    assert allocation.update(percentage: 100)
    assert_not allocation.update(percentage: 101)
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

  test "greatest_community_need? is true only for the dedicated subclass" do
    assert allocations(:greatest_need).greatest_community_need?
    assert_instance_of Allocation::GreatestCommunityNeed, allocations(:greatest_need)

    # A plain ongoing allocation that merely shares the label is NOT the subclass.
    look_alike = @scenario.ongoing_allocations.new(percentage: 10, option: "Greatest Community Need")
    assert_not look_alike.greatest_community_need?
  end

  test "only one Greatest Community Need allocation is allowed per scenario" do
    # greatest_need fixture already occupies the slot in this scenario.
    duplicate = Allocation::GreatestCommunityNeed.new(scenario: @scenario)
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:base], "Greatest Community Need has already been added"

    assert Allocation::GreatestCommunityNeed.new(scenario: scenarios(:two_boston)).valid?
  end

  test "Greatest Community Need defaults to 0% with a fixed label and needs no category or option" do
    gcn = Allocation::GreatestCommunityNeed.new(scenario: scenarios(:two_boston))
    assert_equal 0, gcn.percentage
    assert_equal "Greatest Community Need", gcn.display_label
    assert gcn.valid?
  end
end
