require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "new" do
    get new_registration_path
    assert_response :success
  end

  test "create with valid params adds the user to the org and sends a confirmation email without signing in" do
    assert_difference -> { User.count }, 1 do
      assert_difference -> { OrganizationMembership.count }, 1 do
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
    end

    assert_redirected_to new_session_path
    assert_nil cookies[:session_id]

    user = User.find_by(email_address: "new@example.com")
    assert_not user.confirmed?
    assert user.member_of?(organizations(:arlington))
  end

  test "create without a password creates a passwordless user and emails a sign-in link" do
    assert_difference -> { User.count }, 1 do
      assert_difference -> { OrganizationMembership.count }, 1 do
        post registration_path, params: {
          user: { email_address: "magic@example.com", password: "", password_confirmation: "" }
        }
      end
    end

    user = User.find_by(email_address: "magic@example.com")
    assert_not user.password_set?
    assert user.member_of?(organizations(:arlington))
    assert_enqueued_email_with MagicLinkMailer, :sign_in_link, args: [ user, organizations(:arlington) ]

    assert_redirected_to new_session_path
    assert_nil cookies[:session_id]
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

  test "create with an existing member's email points them to sign in" do
    assert_no_difference [ "User.count", "OrganizationMembership.count" ] do
      assert_no_enqueued_emails do
        post registration_path, params: {
          user: {
            email_address: users(:one).email_address,
            password: "secret123",
            password_confirmation: "secret123"
          }
        }
      end
    end

    assert_redirected_to new_session_path
    follow_redirect!
    assert_select "div", /already have an account/
  end

  test "create with an existing user from another org does not add a membership" do
    assert_no_difference [ "User.count", "OrganizationMembership.count" ] do
      post registration_path, params: {
        user: {
          email_address: users(:two).email_address, # member of boston, not arlington
          password: "secret123",
          password_confirmation: "secret123"
        }
      }
    end

    assert_redirected_to new_session_path
    assert_not users(:two).member_of?(organizations(:arlington))
  end

  test "create with a name stores it on the user" do
    assert_difference -> { User.count }, 1 do
      post registration_path, params: {
        user: {
          name: "Alice Smith",
          email_address: "alice@example.com",
          password: "secret123",
          password_confirmation: "secret123"
        }
      }
    end

    user = User.find_by(email_address: "alice@example.com")
    assert_equal "Alice Smith", user.name
  end
end
