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
end
