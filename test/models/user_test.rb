require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "downcases and strips email_address" do
    user = User.new(email_address: " DOWNCASED@EXAMPLE.COM ")
    assert_equal("downcased@example.com", user.email_address)
  end

  test "organizations through memberships" do
    assert_includes users(:one).organizations, organizations(:arlington)
  end

  test "member_of? reflects membership" do
    assert users(:one).member_of?(organizations(:arlington))
    assert_not users(:one).member_of?(organizations(:boston))
    assert_not users(:one).member_of?(nil)
  end

  test "admin_of? is true for admins and owners only" do
    arlington = organizations(:arlington)
    assert users(:one).admin_of?(arlington)        # owner
    assert users(:admin).admin_of?(arlington)      # admin
    assert_not users(:passwordless).admin_of?(arlington) # member
    assert_not users(:two).admin_of?(arlington)    # non-member
    assert_not users(:one).admin_of?(nil)
  end

  test "owner_of? is true for owners only" do
    arlington = organizations(:arlington)
    assert users(:one).owner_of?(arlington)        # owner
    assert_not users(:admin).owner_of?(arlington)  # admin
    assert_not users(:passwordless).owner_of?(arlington) # member
    assert_not users(:two).owner_of?(arlington)    # non-member
  end

  test "super admins are virtual owners of every organization without a membership" do
    super_admin = users(:super_admin)
    arlington = organizations(:arlington)

    assert_empty super_admin.organizations # no membership rows
    assert super_admin.member_of?(arlington)
    assert super_admin.admin_of?(arlington)
    assert super_admin.owner_of?(arlington)
    assert super_admin.member_of?(organizations(:boston))
  end

  test "super admin checks still reject a nil organization" do
    super_admin = users(:super_admin)
    assert_not super_admin.member_of?(nil)
    assert_not super_admin.admin_of?(nil)
    assert_not super_admin.owner_of?(nil)
  end

  test "is valid without a password" do
    user = User.new(email_address: "passwordless@example.org")
    assert user.valid?
    assert_not user.password_set?
  end

  test "magic_link token round-trips" do
    user = users(:one)
    token = user.generate_token_for(:magic_link)
    assert_equal user, User.find_by_token_for(:magic_link, token)
  end

  test "setting a password invalidates an outstanding magic_link token" do
    user = users(:passwordless)
    token = user.generate_token_for(:magic_link)

    user.update!(password: "secret123", password_confirmation: "secret123")

    assert_nil User.find_by_token_for(:magic_link, token)
  end
end
