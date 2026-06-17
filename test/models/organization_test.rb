require "test_helper"

class OrganizationTest < ActiveSupport::TestCase
  test "valid with a name, subdomain, and website" do
    org = Organization.new(name: "Test Foundation", subdomain: "test", website: "https://example.org/")
    assert org.valid?
  end

  test "requires a name" do
    org = Organization.new(subdomain: "test")
    assert_not org.valid?
    assert_includes org.errors[:name], "can't be blank"
  end

  test "downcases and strips subdomain" do
    org = Organization.new(subdomain: "  ARLington  ")
    assert_equal "arlington", org.subdomain
  end

  test "requires a subdomain" do
    org = Organization.new(name: "Test")
    assert_not org.valid?
    assert_includes org.errors[:subdomain], "can't be blank"
  end

  test "subdomain must be unique" do
    org = Organization.new(name: "Dup", subdomain: organizations(:arlington).subdomain)
    assert_not org.valid?
    assert_includes org.errors[:subdomain], "has already been taken"
  end

  test "rejects invalid subdomain format" do
    %w[ -bad bad- bad_domain UPPER\ space bad.dot ].each do |bad|
      org = Organization.new(name: "Test", subdomain: bad)
      assert_not org.valid?, "expected #{bad.inspect} to be invalid"
    end
  end

  test "rejects reserved subdomains" do
    org = Organization.new(name: "Test", subdomain: "www")
    assert_not org.valid?
    assert_includes org.errors[:subdomain], "is reserved"
  end

  test "requires a website" do
    org = Organization.new(name: "Test", subdomain: "test")
    assert_not org.valid?
    assert_includes org.errors[:website], "can't be blank"
  end

  test "rejects an invalid website" do
    invalid = Organization.new(name: "Test", subdomain: "test2", website: "not a url")
    assert_not invalid.valid?
    assert_includes invalid.errors[:website], "must be a valid URL"
  end
end
