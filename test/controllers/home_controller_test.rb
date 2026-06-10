require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "show is accessible when signed out and offers sign in and sign up" do
    get root_path

    assert_response :success
    assert_select "a[href=?]", new_session_path, text: "Sign in"
    assert_select "a[href=?]", new_registration_path, text: "Sign up"
  end

  test "show greets the user by email and offers sign out when signed in" do
    sign_in_as(users(:one))

    get root_path

    assert_response :success
    assert_select "h1", /Hello, #{Regexp.escape(users(:one).email_address)}/
    assert_select "button", text: "Sign out"
  end
end
