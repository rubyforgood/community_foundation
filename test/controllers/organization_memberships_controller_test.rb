require "test_helper"

class OrganizationMembershipsControllerTest < ActionDispatch::IntegrationTest
  setup do
    host! "arlington.localhost"
    @owner = users(:one)
    @admin = users(:admin)
    @member = users(:passwordless)
    @owner_membership = organization_memberships(:one_arlington)
    @admin_membership = organization_memberships(:admin_arlington)
    @member_membership = organization_memberships(:passwordless_arlington)
  end

  # index

  test "owners and admins can view the members page" do
    sign_in_as(@owner)
    get organization_memberships_path
    assert_response :success

    sign_in_as(@admin)
    get organization_memberships_path
    assert_response :success
  end

  test "plain members are redirected away from the members page" do
    sign_in_as(@member)
    get organization_memberships_path
    assert_redirected_to root_path
  end

  # update — promote

  test "an admin can promote a member to admin" do
    sign_in_as(@admin)
    patch organization_membership_path(@member_membership), params: { role: "admin" }
    assert_redirected_to organization_memberships_path
    assert @member_membership.reload.admin?
  end

  test "a member cannot promote anyone" do
    sign_in_as(@member)
    patch organization_membership_path(@admin_membership), params: { role: "admin" }
    assert_redirected_to root_path
    assert @admin_membership.reload.admin?
  end

  # update — demote

  test "an owner can demote an admin to member" do
    sign_in_as(@owner)
    patch organization_membership_path(@admin_membership), params: { role: "member" }
    assert_redirected_to organization_memberships_path
    assert @admin_membership.reload.member?
  end

  test "an admin cannot demote another admin" do
    sign_in_as(@admin)
    patch organization_membership_path(@admin_membership), params: { role: "member" }
    assert_redirected_to organization_memberships_path
    assert @admin_membership.reload.admin?
  end

  # update — owner rows and roles are protected

  test "owners cannot be changed via update" do
    sign_in_as(@owner)
    patch organization_membership_path(@owner_membership), params: { role: "member" }
    assert_redirected_to organization_memberships_path
    assert @owner_membership.reload.owner?
  end

  test "owner is not an assignable role" do
    sign_in_as(@owner)
    patch organization_membership_path(@member_membership), params: { role: "owner" }
    assert_redirected_to organization_memberships_path
    assert @member_membership.reload.member?
  end
end
