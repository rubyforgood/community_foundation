require "test_helper"

class MagicLinkMailerTest < ActionMailer::TestCase
  test "sign_in_link" do
    user = users(:passwordless)
    organization = organizations(:arlington)

    mail = MagicLinkMailer.sign_in_link(user, organization)

    assert_equal "Your sign-in link", mail.subject
    assert_equal [ user.email_address ], mail.to
    assert_equal [ "no-reply@community-foundations.rowhomelabs.com" ], mail.from

    # Both parts link to the org's subdomain and carry a working magic-link token.
    [ mail.html_part, mail.text_part ].each do |part|
      body = part.body.to_s

      assert_match "http://#{organization.subdomain}.localhost/magic_link", body

      token = CGI.unescape(body[/token=([^"&\s]+)/, 1])
      assert_equal user, User.find_by_token_for(:magic_link, token)
    end
  end
end
