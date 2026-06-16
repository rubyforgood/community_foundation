require "test_helper"

class OrganizationMembershipTest < ActiveSupport::TestCase
  test "valid with a user and organization" do
    membership = OrganizationMembership.new(user: users(:one), organization: organizations(:boston))
    assert membership.valid?
  end

  test "requires a user and an organization" do
    membership = OrganizationMembership.new
    assert_not membership.valid?
    assert_includes membership.errors[:user], "must exist"
    assert_includes membership.errors[:organization], "must exist"
  end

  test "a user cannot join the same organization twice" do
    duplicate = OrganizationMembership.new(user: users(:one), organization: organizations(:arlington))
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:user_id], "has already been taken"
  end

  test "defaults to the member role" do
    membership = OrganizationMembership.new(user: users(:one), organization: organizations(:boston))
    assert membership.member?
    assert_equal "member", membership.role
  end

  test "exposes role predicates" do
    assert organization_memberships(:one_arlington).owner?
    assert organization_memberships(:admin_arlington).admin?
    assert organization_memberships(:passwordless_arlington).member?
  end

  test "requires a role" do
    membership = OrganizationMembership.new(user: users(:one), organization: organizations(:boston))
    membership.role = nil
    assert_not membership.valid?
    assert_includes membership.errors[:role], "can't be blank"
  end
end
