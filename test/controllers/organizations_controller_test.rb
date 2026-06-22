require "test_helper"

class OrganizationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    host! "arlington.localhost"
    @organization = organizations(:arlington)
    @owner = users(:one)
    @admin = users(:admin)
    @member = users(:passwordless)
  end

  # edit

  test "owners can view the edit form" do
    sign_in_as(@owner)
    get edit_organization_path
    assert_response :success
  end

  test "admins are redirected away from the edit form" do
    sign_in_as(@admin)
    get edit_organization_path
    assert_redirected_to root_path
  end

  test "plain members are redirected away from the edit form" do
    sign_in_as(@member)
    get edit_organization_path
    assert_redirected_to root_path
  end

  # update

  test "an owner can change the organization name" do
    sign_in_as(@owner)
    patch organization_path, params: { organization: { name: "Renamed Foundation" } }
    assert_redirected_to edit_organization_path
    assert_equal "Renamed Foundation", @organization.reload.name
  end

  test "an owner can upload a logo" do
    sign_in_as(@owner)
    logo = fixture_file_upload("logo.png", "image/png")
    patch organization_path, params: { organization: { logo: logo } }
    assert_redirected_to edit_organization_path
    assert @organization.reload.logo.attached?
  end

  test "a non-owner cannot update the organization" do
    sign_in_as(@admin)
    patch organization_path, params: { organization: { name: "Hijacked" } }
    assert_redirected_to root_path
    assert_not_equal "Hijacked", @organization.reload.name
  end

  # super admins act as owners on any org they don't belong to

  test "a super admin can view the edit form for an org they don't belong to" do
    sign_in_as(users(:super_admin))
    get edit_organization_path
    assert_response :success
  end

  test "a super admin can update an org they don't belong to" do
    sign_in_as(users(:super_admin))
    patch organization_path, params: { organization: { name: "Renamed by super admin" } }
    assert_redirected_to edit_organization_path
    assert_equal "Renamed by super admin", @organization.reload.name
  end
end
