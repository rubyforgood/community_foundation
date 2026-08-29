class UserLegacyStory < ApplicationRecord
  belongs_to :user

  # Field order within each section of the workbook. The question each field asks
  # lives in config/locales/en.yml under user_legacy_stories.prompts.
  GIVING_HISTORY = %i[ supported_organizations important_nonprofits additional_giving_notes ].freeze
  GUIDED_WRITING = %i[ childhood_generosity influential_people other_motivations family_lessons
                       life_lessons passions core_values legacy_memory unasked_questions ].freeze
  FIELDS = (GIVING_HISTORY + GUIDED_WRITING).freeze
end
