class CreateUserBiographies < ActiveRecord::Migration[8.1]
  def up
    create_table :user_biographies do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.date :birth_date
      t.string :birthplace
      t.text :background
      t.text :formative_experiences
      t.text :what_brought_you_here
      t.text :other_places_lived
      t.text :education
      t.text :military_service
      t.text :professional_licenses
      t.text :employment_history
      t.text :civic_organizations
      t.text :religious_affiliations
      t.text :hobbies
      t.text :marriages
      t.text :parents
      t.text :family_members
      t.text :other

      t.timestamps
    end

    # Copy the existing "About you" answers off users. The users columns are
    # left in place for now and removed in a later migration.
    execute <<~SQL
      INSERT INTO user_biographies (user_id, background, formative_experiences, family_members, created_at, updated_at)
      SELECT id, background, formative_experiences, family, created_at, updated_at
      FROM users
      WHERE background IS NOT NULL OR family IS NOT NULL OR formative_experiences IS NOT NULL
    SQL
  end

  def down
    drop_table :user_biographies
  end
end
