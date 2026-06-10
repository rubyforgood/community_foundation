require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ]

  # Drive the browser against a hostname rather than the default 127.0.0.1 so the
  # tenant resolver reads a bare host as the apex instead of parsing the IP octets
  # as a subdomain (tld_length is 0 in test). Subdomains use "<sub>.localhost".
  Capybara.server_host = "localhost"
  Capybara.app_host = "http://localhost"
  Capybara.always_include_port = true
end
