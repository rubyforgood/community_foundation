ENV["RAILS_ENV"] ||= "test"

# The minimum-coverage gate is enforced separately by script/check_coverage.rb
# (SimpleCov's inline minimum_coverage doesn't propagate a non-zero exit through
# `bin/rails test`). Here we only generate the report.
if ENV["COVERAGE"] == "1"
  require "simplecov"
  SimpleCov.start "rails" do
    command_name ENV.fetch("SIMPLECOV_COMMAND_NAME", "rails-tests")
  end
end

# Hash passwords at bcrypt's minimum cost in tests to improve test speed.
require "bcrypt"
BCrypt::Engine.cost = BCrypt::Engine::MIN_COST

require_relative "../config/environment"
require "rails/test_help"
require_relative "test_helpers/session_test_helper"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers. Under coverage, run serially
    # so SimpleCov's resultset isn't fragmented across forked workers.
    parallelize(workers: ENV["COVERAGE"] == "1" ? 1 : :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end
