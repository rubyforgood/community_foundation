require "test_helper"

class ScenarioTest < ActiveSupport::TestCase
  test "requires a name" do
    scenario = Scenario.new(name: "")
    assert_not scenario.valid?
    assert_includes scenario.errors[:name], "can't be blank"
  end

  test "splits allocations by kind" do
    scenario = scenarios(:one_arlington)
    assert_includes scenario.ongoing_allocations, allocations(:greatest_need)
    assert_includes scenario.one_time_allocations, allocations(:education_grant)
  end

  test "ongoing_percentage_total sums ongoing percentages" do
    assert_equal 30, scenarios(:one_arlington).ongoing_percentage_total
  end

  test "one_time_giving_amount sums one-time allocation amounts" do
    assert_equal 5000, scenarios(:one_arlington).one_time_giving_amount
  end

  test "ongoing_giving_amount is total giving minus one-time gifts" do
    assert_equal 5000, scenarios(:one_arlington).ongoing_giving_amount
  end

  test "ongoing_giving_amount treats a missing total as zero" do
    scenario = Scenario.new
    assert_equal 0, scenario.ongoing_giving_amount
  end

  test "destroys dependent allocations" do
    scenario = scenarios(:one_arlington)
    assert_difference -> { Allocation.count }, -2 do
      scenario.destroy
    end
  end

  test "enable_sharing! generates a token and marks the scenario shared" do
    scenario = scenarios(:one_arlington)
    assert_not scenario.shared?

    scenario.enable_sharing!
    assert scenario.shared?
    assert scenario.share_token.present?
  end

  test "enable_sharing! is idempotent and keeps the existing token" do
    scenario = scenarios(:one_arlington)
    scenario.enable_sharing!
    token = scenario.share_token

    scenario.enable_sharing!
    assert_equal token, scenario.share_token
  end

  test "regenerate_share_token! replaces the token" do
    scenario = scenarios(:one_arlington)
    scenario.enable_sharing!
    token = scenario.share_token

    scenario.regenerate_share_token!
    assert scenario.shared?
    assert_not_equal token, scenario.share_token
  end

  test "disable_sharing! clears the token" do
    scenario = scenarios(:one_arlington)
    scenario.enable_sharing!

    scenario.disable_sharing!
    assert_not scenario.shared?
    assert_nil scenario.share_token
  end

  test "new scenarios are created with a Greatest Community Need allocation at 0%" do
    scenario = users(:one).scenarios.create!(
      organization: organizations(:arlington), name: "Fresh plan", total_giving_amount: 1000)

    gcn = scenario.greatest_community_need
    assert gcn.present?
    assert gcn.greatest_community_need?
    assert_equal 0, gcn.percentage
    assert_includes scenario.ongoing_allocations, gcn
  end
end
