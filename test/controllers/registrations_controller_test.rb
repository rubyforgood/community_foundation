require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "new" do
    get new_registration_path
    assert_response :success
  end

  test "create with valid params sends a confirmation email without signing in" do
    assert_difference -> { User.count }, 1 do
      assert_enqueued_emails 1 do
        post registration_path, params: {
          user: {
            email_address: "new@example.com",
            password: "secret123",
            password_confirmation: "secret123"
          }
        }
      end
    end

    assert_redirected_to new_session_path
    assert_nil cookies[:session_id]
    assert_not User.find_by(email_address: "new@example.com").confirmed?
  end

  test "create with the honeypot filled is silently dropped" do
    assert_no_difference -> { User.count } do
      assert_no_enqueued_emails do
        post registration_path, params: {
          nickname: "spammy mcbot",
          user: {
            email_address: "new@example.com",
            password: "secret123",
            password_confirmation: "secret123"
          }
        }
      end
    end

    # Pretends success so the bot can't detect the rejection.
    assert_redirected_to new_session_path
    assert_nil cookies[:session_id]
  end

  test "create with too-short password" do
    assert_no_difference -> { User.count } do
      post registration_path, params: {
        user: {
          email_address: "new@example.com",
          password: "short",
          password_confirmation: "short"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "create with mismatched password confirmation" do
    assert_no_difference -> { User.count } do
      post registration_path, params: {
        user: {
          email_address: "new@example.com",
          password: "secret123",
          password_confirmation: "nomatch"
        }
      }
    end

    assert_response :unprocessable_entity
    assert_nil cookies[:session_id]
  end

  test "create with already-taken email address" do
    assert_no_difference -> { User.count } do
      post registration_path, params: {
        user: {
          email_address: users(:one).email_address,
          password: "secret123",
          password_confirmation: "secret123"
        }
      }
    end

    assert_response :unprocessable_entity
    assert_nil cookies[:session_id]
  end
end
