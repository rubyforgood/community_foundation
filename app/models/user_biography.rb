class UserBiography < ApplicationRecord
  belongs_to :user

  NARRATIVE_FIELDS = %i[
    background
    what_brought_you_here
    other_places_lived
    education
    military_service
    professional_licenses
    employment_history
    civic_organizations
    religious_affiliations
    hobbies
    marriages
    parents
    family_members
    formative_experiences
    other
  ].freeze
end
