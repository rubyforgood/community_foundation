require "test_helper"

class EmailConfirmationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:unconfirmed)
  end

  test "new" do
    get new_email_confirmation_path
    assert_response :success
  end

  test "create for an unconfirmed user enqueues a confirmation email" do
    post email_confirmation_path, params: { email_address: @user.email_address }
    assert_enqueued_email_with RegistrationMailer, :confirmation, args: [ @user, organizations(:arlington) ]
    assert_redirected_to new_session_path

    follow_redirect!
    assert_notice "Confirmation instructions sent"
  end

  test "create for an already-confirmed user sends no mail" do
    post email_confirmation_path, params: { email_address: users(:one).email_address }
    assert_enqueued_emails 0
    assert_redirected_to new_session_path

    follow_redirect!
    assert_notice "Confirmation instructions sent"
  end

  test "create for an unknown email sends no mail and reveals nothing" do
    post email_confirmation_path, params: { email_address: "missing-user@example.com" }
    assert_enqueued_emails 0
    assert_redirected_to new_session_path

    follow_redirect!
    assert_notice "Confirmation instructions sent"
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

  private
  def assert_notice(text)
    assert_select "div", /#{text}/
  end
end
