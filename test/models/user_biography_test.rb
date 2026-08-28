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

  test "every field has a prompt translation" do
    (%i[ birth_date birthplace ] + UserBiography::NARRATIVE_FIELDS).each do |field|
      assert I18n.t("user_biographies.prompts.#{field}").present?,
        "missing prompt translation for #{field}"
    end
  end

  test "the locale file has no prompts for unknown fields" do
    translated = I18n.t("user_biographies.prompts").keys
    assert_equal (%i[ birth_date birthplace ] + UserBiography::NARRATIVE_FIELDS).sort, translated.sort
  end

  test "placeholders only exist for known fields" do
    placeholders = I18n.t("user_biographies.placeholders").keys
    assert_empty placeholders - UserBiography::NARRATIVE_FIELDS
  end

  test "is destroyed with its user" do
    user = users(:one)
    assert_difference "UserBiography.count", -1 do
      user.destroy
    end
  end
end
