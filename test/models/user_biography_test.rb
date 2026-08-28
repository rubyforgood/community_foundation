require "test_helper"

class UserBiographyTest < ActiveSupport::TestCase
  test "belongs to a user" do
    assert_equal users(:one), user_biographies(:one).user
    assert_equal user_biographies(:one), users(:one).biography
  end

  test "requires a user" do
    biography = UserBiography.new
    assert_not biography.valid?
    assert_includes biography.errors[:user], "must exist"
  end

  test "exposes every narrative field as a text attribute" do
    UserBiography::NARRATIVE_FIELDS.each do |field|
      assert_equal :text, UserBiography.type_for_attribute(field).type, "#{field} should be a text column"
    end
  end

  test "is destroyed with its user" do
    user = users(:one)
    assert_difference "UserBiography.count", -1 do
      user.destroy
    end
  end
end
