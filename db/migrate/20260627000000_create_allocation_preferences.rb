class CreateAllocationPreferences < ActiveRecord::Migration[8.1]
  def change
    create_table :allocation_preferences do |t|
      t.references :allocation, null: false, foreign_key: true
      t.references :allocation_category, null: false, foreign_key: true

      t.timestamps
    end

    add_index :allocation_preferences, [ :allocation_id, :allocation_category_id ], unique: true, name: "index_allocation_preferences_uniqueness"
  end
end
