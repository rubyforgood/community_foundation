# Run using bin/ci

CI.run do
  step "Setup", "bin/setup --skip-server"

  step "Style: Ruby", "bin/rubocop"

  step "Security: Gem audit", "bin/bundler-audit"
  step "Security: Importmap vulnerability audit", "bin/importmap audit"
  step "Security: Brakeman code analysis", "bin/brakeman --quiet --no-pager --exit-on-warn --exit-on-error"
  # Start from a clean, fixture-ready test DB. Coverage runs serially against the
  # shared test DB (see test/test_helper.rb), so reset it first.
  step "Tests: Reset test DB", "env RAILS_ENV=test bin/rails db:test:prepare"
  step "Tests: Rails", "env COVERAGE=1 bin/rails test"
  # COVERAGE_MINIMUM_LINE is the tracked baseline; fails if line coverage drops below it.
  step "Coverage: Line >= 90%", "env COVERAGE_MINIMUM_LINE=90 ruby script/check_coverage.rb"
  step "Tests: Seeds", "env RAILS_ENV=test bin/rails db:seed:replant"

  # Optional: Run system tests
  # step "Tests: System", "bin/rails test:system"

  # Optional: set a green GitHub commit status to unblock PR merge.
  # Requires the `gh` CLI and `gh extension install basecamp/gh-signoff`.
  # if success?
  #   step "Signoff: All systems go. Ready for merge and deploy.", "gh signoff"
  # else
  #   failure "Signoff: CI failed. Do not merge or deploy.", "Fix the issues and try again."
  # end
end
