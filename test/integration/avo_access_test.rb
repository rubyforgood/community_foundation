require "test_helper"

class AvoAccessTest < ActionDispatch::IntegrationTest
  test "super_admins can reach the Avo dashboard" do
    sign_in_as users(:super_admin)
    get "/avo"
    # /avo lands on the first resource (there is no custom dashboard yet).
    follow_redirect!
    assert_response :success
  end

  test "non-super_admins are redirected to the home page" do
    sign_in_as users(:one)
    get "/avo"
    assert_redirected_to "/"
  end

  test "signed-out visitors are redirected to the home page" do
    get "/avo"
    assert_redirected_to "/"
  end

  test "a super_admin can promote another user via the User resource" do
    sign_in_as users(:super_admin)
    user = users(:one)
    assert_not user.super_admin?

    patch "/avo/resources/users/#{user.id}", params: { user: { super_admin: "1" } }

    assert user.reload.super_admin?
  end
end
