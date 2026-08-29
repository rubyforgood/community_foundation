require "application_system_test_case"

# Walks the happy path a brand-new member takes on a tenant: sign up, confirm
# via the emailed link, fill in About You (autosave), build a giving scenario,
# share it, and view the shared page anonymously.
class UserJourneyTest < ApplicationSystemTestCase
  include ActiveJob::TestHelper

  EMAIL = "journey@example.com".freeze
  TENANT_HOST = "http://arlington.localhost".freeze

  setup do
    @original_app_host = Capybara.app_host
    Capybara.app_host = TENANT_HOST
  end

  teardown do
    Capybara.app_host = @original_app_host
  end

  test "a new member signs up, confirms, fills out About You, builds and shares a scenario" do
    # Landing → sign up
    visit "/"
    assert_selector "h1", text: "Your Legacy Starts Here"
    within("nav") { click_link "Log in" }
    click_link "Sign up"

    fill_in "Full name", with: "Journey Tester"
    fill_in "user_email_address", with: EMAIL
    fill_in "user_password", with: "password123"
    fill_in "user_password_confirmation", with: "password123"
    click_button "Sign up"
    assert_text "Check your email to confirm your account before signing in."

    # Follow the confirmation email; it confirms and signs the user in
    perform_enqueued_jobs
    mail = ActionMailer::Base.deliveries.last
    assert_equal [ EMAIL ], mail.to
    visit extract_path(mail, "/email_confirmation")
    assert_text "Your email address has been confirmed."
    assert_selector "h1", text: "Welcome to your workspace"

    # About You autosaves as you type
    click_link "About you"
    assert_selector "h1", text: "About you"
    fill_in "user_biography_birthplace", with: "Arlington, VA"
    fill_in "user_biography_background", with: "Grew up on a farm."
    assert_text "Saved."

    user = User.find_by!(email_address: EMAIL)
    assert_equal "Arlington, VA", user.biography.birthplace
    assert_equal "Grew up on a farm.", user.biography.background

    visit "/users/biography"
    assert_field "user_biography_birthplace", with: "Arlington, VA"

    # Build a scenario
    visit "/dashboard"
    click_link "Explore options"
    click_link "Create scenario"
    fill_in "Name", with: "Education focus"
    click_button "Create scenario"
    assert_selector "h1", text: "Education focus"
    assert_text "Greatest Community Need"

    click_link "Add amount"
    fill_in "Total giving amount", with: 100_000
    find("button[aria-label='Save total giving amount']").click
    assert_text "$100,000"

    within one_time_section do
      click_button "+ Add allocation"
      click_button "Select a category"
      find("button[data-name='Education']").click
      fill_in "Amount", with: 5_000
      click_button "Create"
    end
    assert_text "Education"
    assert_text "$5,000"

    # Share and view the read-only page without signing in
    click_button "Share"
    click_button "Create share link"
    assert_selector "input[readonly][value*='/public/scenarios/']"

    token = user.scenarios.find_by!(name: "Education focus").share_token
    assert token.present?

    Capybara.using_session(:anonymous_visitor) do
      visit "/public/scenarios/#{token}"
      assert_text "Read-only shared view"
      assert_selector "h1", text: "Education focus"
      assert_text "Education"
    end
  end

  private

  def one_time_section
    find("h3", text: /one time giving/i).ancestor("[data-controller='dialog']")
  end

  # Pull the first link containing `prefix` out of the email and return it as a
  # path + query so Capybara routes it through the running test server.
  def extract_path(mail, prefix)
    body = mail.html_part&.body&.decoded || mail.body.decoded
    url = body[%r{https?://[^"'\s<]+#{Regexp.escape(prefix)}[^"'\s<]*}]
    assert url, "No #{prefix} link found in email"
    uri = URI.parse(url)
    [ uri.path, uri.query ].compact.join("?")
  end
end
