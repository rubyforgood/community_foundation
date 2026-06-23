require "test_helper"

class Users::ProfilesControllerTest < ActionDispatch::IntegrationTest
  setup { host! "arlington.localhost" }

  test "show requires authentication" do
    get users_profile_path
    assert_redirected_to new_session_path
  end

  test "show for an authenticated user" do
    sign_in_as users(:one)
    get users_profile_path
    assert_response :success
  end

  test "a user can set their name" do
    user = users(:one)
    sign_in_as user

    patch users_profile_path, params: {
      user: { name: "Alice Smith" }
    }

    assert_redirected_to users_profile_path
    assert_equal "Alice Smith", user.reload.name
  end

  test "a user can clear their name" do
    user = users(:one)
    user.update!(name: "Bob Jones")
    sign_in_as user

    patch users_profile_path, params: {
      user: { name: "" }
    }

    assert_redirected_to users_profile_path
    assert_equal "", user.reload.name
  end

  test "rejects a name over 100 characters" do
    user = users(:one)
    sign_in_as user

    patch users_profile_path, params: {
      user: { name: "A" * 101 }
    }

    assert_response :unprocessable_entity
    assert_nil user.reload.name
  end
end
