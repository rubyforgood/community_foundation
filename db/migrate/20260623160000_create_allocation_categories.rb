class CreateAllocationCategories < ActiveRecord::Migration[8.1]
  def change
    create_table :allocation_categories do |t|
      t.references :organization, null: false, foreign_key: true
      t.string :type, null: false
      t.string :name, null: false
      t.references :parent, foreign_key: { to_table: :allocation_categories }

      t.timestamps
    end

    add_index :allocation_categories, [ :organization_id, :type ]
  end
end
