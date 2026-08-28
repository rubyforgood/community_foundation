require "test_helper"

class Users::BiographiesControllerTest < ActionDispatch::IntegrationTest
  test "show requires authentication" do
    get users_biography_path
    assert_redirected_to new_session_path
  end

  test "show for an authenticated user" do
    sign_in_as users(:one)
    get users_biography_path
    assert_response :success
    assert_select "h1", "About you"
  end

  test "show for a user with no biography yet" do
    sign_in_as users(:passwordless)
    get users_biography_path
    assert_response :success
    assert_select "h1", "About you"
  end

  test "first save creates a biography for the user" do
    user = users(:passwordless)
    sign_in_as user
    assert_nil user.biography

    assert_difference "UserBiography.count", 1 do
      patch users_biography_path, params: { user_biography: { education: "State university." } }
    end

    assert_redirected_to users_biography_path
    assert_equal "State university.", user.reload.biography.education
  end

  test "a user can save basics and narrative fields" do
    user = users(:one)
    sign_in_as user

    patch users_biography_path, params: {
      user_biography: {
        birth_date: "1960-04-12",
        birthplace: "Richmond, VA",
        background: "Grew up in Arlington.",
        family_members: "Two kids.",
        formative_experiences: "A mentor changed my path."
      }
    }

    assert_redirected_to users_biography_path
    biography = user.reload.biography
    assert_equal Date.new(1960, 4, 12), biography.birth_date
    assert_equal "Richmond, VA", biography.birthplace
    assert_equal "Grew up in Arlington.", biography.background
    assert_equal "Two kids.", biography.family_members
    assert_equal "A mentor changed my path.", biography.formative_experiences
  end

  test "autosave (turbo_stream) persists and responds with a Saved toast without redirecting" do
    user = users(:one)
    sign_in_as user

    patch users_biography_path, params: { user_biography: { background: "Autosaved text." } }, as: :turbo_stream

    assert_response :success
    assert_equal "text/vnd.turbo-stream.html", response.media_type
    # Appends a toast into the flash container rather than navigating away.
    assert_match %r{turbo-stream action="append" target="flash"}, response.body
    assert_match "Saved.", response.body
    assert_equal "Autosaved text.", user.reload.biography.background
  end

  test "a user can clear their biography fields" do
    user = users(:one)
    user.biography.update!(background: "Something", hobbies: "Sailing", formative_experiences: "A moment")
    sign_in_as user

    patch users_biography_path, params: {
      user_biography: { background: "", hobbies: "", formative_experiences: "" }
    }

    assert_redirected_to users_biography_path
    biography = user.reload.biography
    assert_equal "", biography.background
    assert_equal "", biography.hobbies
    assert_equal "", biography.formative_experiences
  end
end
