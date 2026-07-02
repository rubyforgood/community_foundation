require "test_helper"

class DashboardsControllerTest < ActionDispatch::IntegrationTest
  test "requires authentication" do
    get dashboard_url
    assert_redirected_to new_session_path
  end

  test "renders the workspace dashboard for a signed-in member" do
    sign_in_as(users(:one))

    get dashboard_url

    assert_response :success
    assert_select "h1", "Welcome to your workspace"
    assert_select "a[href=?]", users_story_path, text: "About you"
    assert_select "a[href=?]", scenarios_path, text: "Explore options"
    # The nav brand/logo links back to the dashboard for signed-in users.
    assert_select "nav a[href=?]", dashboard_path
  end

  test "a signed-in non-member is redirected to the apex" do
    sign_in_as(users(:two)) # member of boston, not arlington

    get dashboard_url

    assert_redirected_to root_url(subdomain: false)
  end
end
