require "test_helper"

class OrganizationMembership::RoleUpdaterTest < ActiveSupport::TestCase
  setup do
    @owner = users(:one)
    @admin = users(:admin)
    @member_membership = organization_memberships(:passwordless_arlington)
    @admin_membership = organization_memberships(:admin_arlington)
    @owner_membership = organization_memberships(:one_arlington)
  end

  test "an admin can promote a member to admin" do
    result = OrganizationMembership::RoleUpdater.new(@member_membership, actor: @admin, role: "admin").call
    assert result.updated?
    assert result.success?
    assert @member_membership.reload.admin?
  end

  test "an owner can demote an admin to member" do
    result = OrganizationMembership::RoleUpdater.new(@admin_membership, actor: @owner, role: "member").call
    assert result.updated?
    assert @admin_membership.reload.member?
  end

  test "an admin cannot demote and the role is unchanged" do
    result = OrganizationMembership::RoleUpdater.new(@admin_membership, actor: @admin, role: "member").call
    assert result.forbidden?
    assert_not result.success?
    assert @admin_membership.reload.admin?
  end

  test "owner rows are rejected" do
    result = OrganizationMembership::RoleUpdater.new(@owner_membership, actor: @owner, role: "member").call
    assert result.rejected?
    assert @owner_membership.reload.owner?
  end

  test "owner is not an assignable role" do
    result = OrganizationMembership::RoleUpdater.new(@member_membership, actor: @owner, role: "owner").call
    assert result.rejected?
    assert @member_membership.reload.member?
  end

  test "unknown roles are rejected" do
    result = OrganizationMembership::RoleUpdater.new(@member_membership, actor: @owner, role: "wizard").call
    assert result.rejected?
    assert @member_membership.reload.member?
  end
end
