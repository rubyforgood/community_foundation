require "test_helper"

class Users::LegacyStoriesControllerTest < ActionDispatch::IntegrationTest
  test "show requires authentication" do
    get users_legacy_story_path
    assert_redirected_to new_session_path
  end

  test "show for an authenticated user" do
    sign_in_as users(:one)
    get users_legacy_story_path
    assert_response :success
    assert_select "h1", "Your legacy"
    assert_select "textarea", UserLegacyStory::FIELDS.size
  end

  test "show for a user who has never started the workbook" do
    sign_in_as users(:passwordless)
    get users_legacy_story_path
    assert_response :success
    assert_select "h1", "Your legacy"
  end

  test "a user can save their giving history and guided writing answers" do
    user = users(:one)
    sign_in_as user

    patch users_legacy_story_path, params: {
      user_legacy_story: {
        supported_organizations: "Arlington Food Assistance Center.",
        childhood_generosity: "A canned food drive in third grade.",
        legacy_memory: "That I was generous with my time."
      }
    }

    assert_redirected_to users_legacy_story_path
    story = user.reload.user_legacy_story
    assert_equal "Arlington Food Assistance Center.", story.supported_organizations
    assert_equal "A canned food drive in third grade.", story.childhood_generosity
    assert_equal "That I was generous with my time.", story.legacy_memory
  end


  test "autosave (turbo_stream) persists and responds with a Saved toast without redirecting" do
    user = users(:one)
    sign_in_as user

    patch users_legacy_story_path,
      params: { user_legacy_story: { passions: "Autosaved text." } }, as: :turbo_stream

    assert_response :success
    assert_equal "text/vnd.turbo-stream.html", response.media_type
    # Appends a toast into the flash container rather than navigating away.
    assert_match %r{turbo-stream action="append" target="flash"}, response.body
    assert_match "Saved.", response.body
    assert_equal "Autosaved text.", user.reload.user_legacy_story.passions
  end


  test "a user can clear their answers" do
    user = users(:one)
    sign_in_as user

    patch users_legacy_story_path, params: {
      user_legacy_story: { supported_organizations: "", important_nonprofits: "", core_values: "" }
    }

    assert_redirected_to users_legacy_story_path
    story = user.reload.user_legacy_story
    assert_equal "", story.supported_organizations
    assert_equal "", story.important_nonprofits
    assert_equal "", story.core_values
  end
end
