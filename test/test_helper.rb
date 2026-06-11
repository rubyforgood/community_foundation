ENV["RAILS_ENV"] ||= "test"

# Hash passwords at bcrypt's minimum cost in tests to improve test speed.
require "bcrypt"
BCrypt::Engine.cost = BCrypt::Engine::MIN_COST

require_relative "../config/environment"
require "rails/test_help"
require_relative "test_helpers/session_test_helper"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end
