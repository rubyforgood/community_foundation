require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "show on a tenant subdomain offers sign up and log in when signed out" do
    get root_url

    assert_response :success
    assert_select "h1", "Your Legacy Starts Here"
    assert_select "a[href=?]", new_registration_path, text: "Sign up"
    assert_select "a[href=?]", new_session_path, text: "Log in"
    # The nav brand/logo links to the marketing home when signed out.
    assert_select "nav a[href=?]", root_path
  end

  test "show still renders the marketing page for a signed-in member" do
    sign_in_as(users(:one))

    get root_url

    assert_response :success
    assert_select "h1", "Your Legacy Starts Here"
  end

  test "a signed-in non-member is redirected to the apex" do
    sign_in_as(users(:two)) # member of boston, not arlington

    get root_url

    assert_redirected_to root_url(subdomain: false)
  end

  test "an unknown subdomain returns 404" do
    host! "bogus.localhost"
    get root_url

    assert_response :not_found
  end

  test "the apex shows a generic landing with no sign in" do
    host! "localhost"
    get root_url

    assert_response :success
    assert_select "h1", "Community Foundations"
    assert_select "a[href=?]", new_session_path, count: 0
    assert_select "a[href=?]", root_url(subdomain: organizations(:arlington).subdomain), text: organizations(:arlington).name
    assert_select "a[href=?]", root_url(subdomain: organizations(:boston).subdomain), text: organizations(:boston).name
  end

  test "a non-home page on the apex redirects to the apex home" do
    host! "localhost"
    get new_session_url

    assert_redirected_to root_url(subdomain: false)
  end
end
