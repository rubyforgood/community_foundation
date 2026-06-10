require "test_helper"

class EmailConfirmationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    host! "arlington.localhost"
    @user = users(:unconfirmed)
  end

  test "show with a valid token confirms the user and signs them in" do
    token = @user.generate_token_for(:email_confirmation)

    get email_confirmation_path(token: token)

    assert @user.reload.confirmed?
    assert_redirected_to root_path
    assert cookies[:session_id]
  end

  test "show with an invalid token" do
    get email_confirmation_path(token: "invalid")

    assert_not @user.reload.confirmed?
    assert_redirected_to new_session_path
    assert_nil cookies[:session_id]
  end

  test "show with a token for an already-confirmed user is rejected" do
    token = @user.generate_token_for(:email_confirmation)
    @user.confirm!

    get email_confirmation_path(token: token)

    assert_redirected_to new_session_path
    assert_nil cookies[:session_id]
  end
end
