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

  test "lists every member in the organization" do
    sign_in_as(@owner)
    get organization_memberships_path

    assert_select "turbo-frame li", text: /#{@owner.email_address}/
    assert_select "turbo-frame li", text: /#{@admin.email_address}/
    assert_select "turbo-frame li", text: /#{@member.email_address}/
  end

  test "does not show members from another organization" do
    sign_in_as(@owner)
    get organization_memberships_path

    assert_select "turbo-frame li", text: /two@example.com/, count: 0
  end

  test "filters members by email on the server" do
    sign_in_as(@owner)
    get organization_memberships_path(q: "admin")

    assert_select "turbo-frame li", text: /#{@admin.email_address}/
    assert_select "turbo-frame li", text: /#{@owner.email_address}/, count: 0
  end

  test "filters members by user name on the server" do
    @member.update!(name: "Zelda Fitzgerald")
    sign_in_as(@owner)
    get organization_memberships_path(q: "zelda")

    assert_select "turbo-frame li", text: /Zelda Fitzgerald/
    assert_select "turbo-frame li", text: /#{@owner.email_address}/, count: 0
  end

  test "filters members by role" do
    sign_in_as(@owner)
    get organization_memberships_path(roles: [ "admin" ])

    assert_select "turbo-frame li", text: /#{@admin.email_address}/
    assert_select "turbo-frame li", text: /#{@owner.email_address}/, count: 0
    assert_select "turbo-frame li", text: /#{@member.email_address}/, count: 0
  end

  test "filters members by multiple roles" do
    sign_in_as(@owner)
    get organization_memberships_path(roles: [ "owner", "member" ])

    assert_select "turbo-frame li", text: /#{@owner.email_address}/
    assert_select "turbo-frame li", text: /#{@member.email_address}/
    assert_select "turbo-frame li", text: /#{@admin.email_address}/, count: 0
  end

  test "combines the user search and role filters" do
    sign_in_as(@owner)
    get organization_memberships_path(q: "example.com", roles: [ "owner" ])

    assert_select "turbo-frame li", text: /#{@owner.email_address}/
    assert_select "turbo-frame li", text: /#{@admin.email_address}/, count: 0
  end

  test "ignores unknown role values" do
    sign_in_as(@owner)
    get organization_memberships_path(roles: [ "superuser" ])

    # No valid roles selected → no role filter applied, every member shows.
    assert_select "turbo-frame li", text: /#{@owner.email_address}/
    assert_select "turbo-frame li", text: /#{@admin.email_address}/
    assert_select "turbo-frame li", text: /#{@member.email_address}/
  end

  test "shows an empty state when no members match" do
    sign_in_as(@owner)
    get organization_memberships_path(q: "nobody-matches-this")

    assert_select "turbo-frame li", text: /No members match/
  end

  test "paginates results" do
    sign_in_as(@owner)
    arlington = organizations(:arlington)
    # Create more members than fit on one page so a second page exists.
    (OrganizationMembershipsController::PER_PAGE + 5).times do |i|
      user = User.create!(email_address: "bulk#{i}@example.com", confirmed_at: Time.current)
      arlington.organization_memberships.create!(user: user, role: "member")
    end

    get organization_memberships_path
    assert_select "turbo-frame li", count: OrganizationMembershipsController::PER_PAGE

    get organization_memberships_path(page: 2)
    assert_select "turbo-frame li", minimum: 1
  end

  # update — promote

  test "an admin can promote a member to admin" do
    sign_in_as(@admin)
    patch organization_membership_path(@member_membership), params: { role: "admin" }
    assert_redirected_to organization_memberships_path
    assert @member_membership.reload.admin?
  end

  test "update preserves the active filter and page on redirect" do
    sign_in_as(@admin)
    patch organization_membership_path(@member_membership), params: { role: "admin", q: "passwordless", page: "2" }
    assert_redirected_to organization_memberships_path(q: "passwordless", page: "2")
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
