require "test_helper"

class MagicLinksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @member = users(:one) # member of arlington
  end

  test "new" do
    get new_magic_link_path
    assert_response :success
  end

  test "create for a member enqueues a sign-in link" do
    post magic_link_path, params: { email_address: @member.email_address }

    assert_enqueued_email_with MagicLinkMailer, :sign_in_link, args: [ @member, organizations(:arlington) ]
    assert_redirected_to new_session_path

    follow_redirect!
    assert_select "div", /we've sent a sign-in link/
  end

  test "create for a passwordless member enqueues a sign-in link" do
    post magic_link_path, params: { email_address: users(:passwordless).email_address }

    assert_enqueued_email_with MagicLinkMailer, :sign_in_link, args: [ users(:passwordless), organizations(:arlington) ]
    assert_redirected_to new_session_path
  end

  test "create for a non-member of this org sends no mail and reveals nothing" do
    post magic_link_path, params: { email_address: users(:two).email_address } # member of boston

    assert_enqueued_emails 0
    assert_redirected_to new_session_path
    follow_redirect!
    assert_select "div", /we've sent a sign-in link/
  end

  test "create for an unknown email sends no mail and reveals nothing" do
    post magic_link_path, params: { email_address: "missing-user@example.com" }

    assert_enqueued_emails 0
    assert_redirected_to new_session_path
    follow_redirect!
    assert_select "div", /we've sent a sign-in link/
  end

  test "create with the honeypot filled is silently dropped" do
    assert_no_enqueued_emails do
      post magic_link_path, params: { nickname: "spammy mcbot", email_address: @member.email_address }
    end

    assert_redirected_to new_session_path
  end

  test "show with a valid token for a confirmed member signs them in" do
    token = @member.generate_token_for(:magic_link)

    get magic_link_path(token: token)

    assert_redirected_to root_url
    assert cookies[:session_id]
  end

  test "show with a valid token for an unconfirmed passwordless signup confirms and signs in" do
    user = User.create!(email_address: "fresh@example.com")
    organizations(:arlington).organization_memberships.create!(user: user)
    token = user.generate_token_for(:magic_link)

    get magic_link_path(token: token)

    assert user.reload.confirmed?
    assert_redirected_to root_url
    assert cookies[:session_id]
  end

  test "show with an invalid token" do
    get magic_link_path(token: "invalid")

    assert_redirected_to new_session_path
    assert_nil cookies[:session_id]
  end

  test "show with a token for a user in another org is rejected" do
    token = users(:two).generate_token_for(:magic_link) # member of boston, not arlington

    get magic_link_path(token: token)

    assert_redirected_to new_session_path
    assert_nil cookies[:session_id]
  end
end
