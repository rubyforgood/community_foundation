require "test_helper"

class Users::StoriesControllerTest < ActionDispatch::IntegrationTest
  test "show requires authentication" do
    get users_story_path
    assert_redirected_to new_session_path
  end

  test "show for an authenticated user" do
    sign_in_as users(:one)
    get users_story_path
    assert_response :success
    assert_select "h1", "About you"
  end

  test "a user can save their background, family, and formative experiences" do
    user = users(:one)
    sign_in_as user

    patch users_story_path, params: {
      user: {
        background: "Grew up in Arlington.",
        family: "Two kids.",
        formative_experiences: "A mentor changed my path."
      }
    }

    assert_redirected_to users_story_path
    user.reload
    assert_equal "Grew up in Arlington.", user.background
    assert_equal "Two kids.", user.family
    assert_equal "A mentor changed my path.", user.formative_experiences
  end

  test "autosave (turbo_stream) persists and responds with a Saved toast without redirecting" do
    user = users(:one)
    sign_in_as user

    patch users_story_path, params: { user: { background: "Autosaved text." } }, as: :turbo_stream

    assert_response :success
    assert_equal "text/vnd.turbo-stream.html", response.media_type
    # Appends a toast into the flash container rather than navigating away.
    assert_match %r{turbo-stream action="append" target="flash"}, response.body
    assert_match "Saved.", response.body
    assert_equal "Autosaved text.", user.reload.background
  end

  test "a user can clear their story fields" do
    user = users(:one)
    user.update!(background: "Something", family: "Someone", formative_experiences: "A moment")
    sign_in_as user

    patch users_story_path, params: {
      user: { background: "", family: "", formative_experiences: "" }
    }

    assert_redirected_to users_story_path
    user.reload
    assert_equal "", user.background
    assert_equal "", user.family
    assert_equal "", user.formative_experiences
  end
end
