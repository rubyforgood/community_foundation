#!/usr/bin/env ruby
# Fails (non-zero exit) if the last SimpleCov run's line coverage is below
# COVERAGE_MINIMUM_LINE. Run after `COVERAGE=1 bin/rails test`. SimpleCov's
# inline minimum_coverage prints a warning but doesn't fail `bin/rails test`,
# so the CI gate lives here instead.

require "json"

minimum = Float(ENV.fetch("COVERAGE_MINIMUM_LINE", "0"))
last_run = File.expand_path("../coverage/.last_run.json", __dir__)

unless File.exist?(last_run)
  abort "Coverage summary not found at #{last_run}. Run tests with COVERAGE=1 first."
end

covered = JSON.parse(File.read(last_run)).dig("result", "line")
abort "Could not read line coverage from #{last_run}." unless covered

if covered < minimum
  abort format("Line coverage %.2f%% is below the required minimum %.2f%%.", covered, minimum)
end

puts format("Line coverage %.2f%% meets the required minimum %.2f%%.", covered, minimum)
