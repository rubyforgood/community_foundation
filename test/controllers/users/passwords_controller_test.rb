require "test_helper"

class Users::PasswordsControllerTest < ActionDispatch::IntegrationTest
  setup { host! "arlington.localhost" }

  test "show requires authentication" do
    get users_password_path
    assert_redirected_to new_session_path
  end

  test "show for an authenticated user" do
    sign_in_as users(:one)
    get users_password_path
    assert_response :success
  end

  test "a passwordless user adds a first password without a current password" do
    user = users(:passwordless)
    sign_in_as user

    patch users_password_path, params: {
      user: { password: "secret123", password_confirmation: "secret123" }
    }

    assert_redirected_to users_password_path
    assert user.reload.password_set?
    assert user.authenticate("secret123")
  end

  test "a user with a password must supply the correct current password" do
    user = users(:one)
    sign_in_as user

    patch users_password_path, params: {
      current_password: "wrong",
      user: { password: "newsecret123", password_confirmation: "newsecret123" }
    }

    assert_response :unprocessable_entity
    assert_not user.reload.authenticate("newsecret123")
  end

  test "a user with a password can change it with the correct current password" do
    user = users(:one)
    sign_in_as user

    patch users_password_path, params: {
      current_password: "password",
      user: { password: "newsecret123", password_confirmation: "newsecret123" }
    }

    assert_redirected_to users_password_path
    assert user.reload.authenticate("newsecret123")
  end

  test "rejects a too-short password" do
    user = users(:passwordless)
    sign_in_as user

    patch users_password_path, params: {
      user: { password: "short", password_confirmation: "short" }
    }

    assert_response :unprocessable_entity
    assert_not user.reload.password_set?
  end

  test "rejects a mismatched confirmation" do
    user = users(:passwordless)
    sign_in_as user

    patch users_password_path, params: {
      user: { password: "secret123", password_confirmation: "nomatch" }
    }

    assert_response :unprocessable_entity
    assert_not user.reload.password_set?
  end
end
