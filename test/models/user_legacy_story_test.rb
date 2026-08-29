require "test_helper"

class UserLegacyStoryTest < ActiveSupport::TestCase
  test "every field has a prompt translation" do
    UserLegacyStory::FIELDS.each do |field|
      assert I18n.t("user_legacy_stories.prompts.#{field}").present?,
        "missing prompt translation for #{field}"
    end
  end

  test "the locale file has no prompts for unknown fields" do
    translated = I18n.t("user_legacy_stories.prompts").keys
    assert_equal UserLegacyStory::FIELDS.sort, translated.sort
  end

  test "every field is a real column" do
    assert_empty UserLegacyStory::FIELDS.map(&:to_s) - UserLegacyStory.column_names
  end
end
