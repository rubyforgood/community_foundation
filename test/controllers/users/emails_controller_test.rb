require "test_helper"

class Users::EmailsControllerTest < ActionDispatch::IntegrationTest
  setup { host! "arlington.localhost" }

  test "show requires authentication" do
    get users_email_path
    assert_redirected_to new_session_path
  end

  test "show for an authenticated user" do
    sign_in_as users(:one)
    get users_email_path
    assert_response :success
  end

  test "a user with a password sets a pending email with the correct current password" do
    user = users(:one)
    sign_in_as user

    assert_enqueued_email_with RegistrationMailer, :email_change, args: [user, organizations(:arlington)] do
      patch users_email_path, params: {
        current_password: "password",
        user: { unconfirmed_email: "new@example.com" }
      }
    end

    assert_redirected_to users_email_path
    assert_equal "new@example.com", user.reload.unconfirmed_email
    assert_equal "one@example.com", user.email_address
  end

  test "normalizes the pending email" do
    user = users(:one)
    sign_in_as user

    patch users_email_path, params: {
      current_password: "password",
      user: { unconfirmed_email: "  NEW@Example.com  " }
    }

    assert_equal "new@example.com", user.reload.unconfirmed_email
  end

  test "a user with a password must supply the correct current password" do
    user = users(:one)
    sign_in_as user

    assert_no_enqueued_emails do
      patch users_email_path, params: {
        current_password: "wrong",
        user: { unconfirmed_email: "new@example.com" }
      }
    end

    assert_response :unprocessable_entity
    assert_nil user.reload.unconfirmed_email
  end

  test "a passwordless user sets a pending email without a current password" do
    user = users(:passwordless)
    sign_in_as user

    assert_enqueued_email_with RegistrationMailer, :email_change, args: [user, organizations(:arlington)] do
      patch users_email_path, params: {
        user: { unconfirmed_email: "new@example.com" }
      }
    end

    assert_redirected_to users_email_path
    assert_equal "new@example.com", user.reload.unconfirmed_email
  end

  test "rejects an invalid email format" do
    user = users(:one)
    sign_in_as user

    assert_no_enqueued_emails do
      patch users_email_path, params: {
        current_password: "password",
        user: { unconfirmed_email: "not-an-email" }
      }
    end

    assert_response :unprocessable_entity
    assert_nil user.reload.unconfirmed_email
  end

  test "rejects the current email address" do
    user = users(:one)
    sign_in_as user

    assert_no_enqueued_emails do
      patch users_email_path, params: {
        current_password: "password",
        user: { unconfirmed_email: "one@example.com" }
      }
    end

    assert_response :unprocessable_entity
    assert_nil user.reload.unconfirmed_email
  end

  test "rejects an email already taken by another user" do
    user = users(:one)
    sign_in_as user

    assert_no_enqueued_emails do
      patch users_email_path, params: {
        current_password: "password",
        user: { unconfirmed_email: users(:two).email_address }
      }
    end

    assert_response :unprocessable_entity
    assert_nil user.reload.unconfirmed_email
  end

  test "resubmitting overwrites a prior pending email" do
    user = users(:one)
    user.update!(unconfirmed_email: "first@example.com")
    sign_in_as user

    patch users_email_path, params: {
      current_password: "password",
      user: { unconfirmed_email: "second@example.com" }
    }

    assert_equal "second@example.com", user.reload.unconfirmed_email
  end

  test "confirm swaps the email and does not create a session" do
    user = users(:one)
    user.update!(unconfirmed_email: "new@example.com")
    token = user.generate_token_for(:email_change)

    get confirm_users_email_path(token: token)

    assert_redirected_to new_session_path
    user.reload
    assert_equal "new@example.com", user.email_address
    assert_nil user.unconfirmed_email
    assert_nil cookies[:session_id]
  end

  test "confirm with an invalid token leaves the email unchanged" do
    user = users(:one)
    user.update!(unconfirmed_email: "new@example.com")

    get confirm_users_email_path(token: "bogus")

    assert_redirected_to new_session_path
    user.reload
    assert_equal "one@example.com", user.email_address
    assert_equal "new@example.com", user.unconfirmed_email
  end

  test "confirm with a stale token (pending email replaced) is rejected" do
    user = users(:one)
    user.update!(unconfirmed_email: "new@example.com")
    token = user.generate_token_for(:email_change)

    # Replace the pending email, invalidating the token generated above.
    user.update!(unconfirmed_email: "other@example.com")

    get confirm_users_email_path(token: token)

    assert_redirected_to new_session_path
    assert_equal "one@example.com", user.reload.email_address
  end

  test "confirm fails gracefully when the email was taken in the meantime" do
    user = users(:one)
    user.update!(unconfirmed_email: "taken@example.com")
    token = user.generate_token_for(:email_change)

    User.create!(email_address: "taken@example.com", confirmed_at: Time.current)

    get confirm_users_email_path(token: token)

    assert_redirected_to new_session_path
    user.reload
    assert_equal "one@example.com", user.email_address
    assert_nil user.unconfirmed_email
  end
end
