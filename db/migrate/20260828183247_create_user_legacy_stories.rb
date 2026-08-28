class CreateUserLegacyStories < ActiveRecord::Migration[8.1]
  def change
    create_table :user_legacy_stories do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }

      # Giving History
      t.text :supported_organizations
      t.text :important_nonprofits
      t.text :additional_giving_notes

      # Guided Writing Exercises
      t.text :childhood_generosity
      t.text :influential_people
      t.text :other_motivations
      t.text :family_lessons
      t.text :life_lessons
      t.text :passions
      t.text :core_values
      t.text :legacy_memory
      t.text :unasked_questions

      t.timestamps
    end
  end
end
