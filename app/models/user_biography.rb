class UserBiography < ApplicationRecord
  belongs_to :user

  # Field order within each section of the biography form. The question each
  # field asks lives in config/locales/en.yml under user_biographies.prompts.
  ROOTS = %i[ what_brought_you_here other_places_lived background ].freeze
  EDUCATION_AND_CAREER = %i[ education military_service professional_licenses employment_history ].freeze
  COMMUNITY_AND_INTERESTS = %i[ civic_organizations religious_affiliations hobbies ].freeze
  FAMILY = %i[ marriages parents family_members ].freeze
  REFLECTIONS = %i[ formative_experiences other ].freeze
  NARRATIVE_FIELDS = (ROOTS + EDUCATION_AND_CAREER + COMMUNITY_AND_INTERESTS + FAMILY + REFLECTIONS).freeze
end
