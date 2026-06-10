class CreateScenarios < ActiveRecord::Migration[8.1]
  def change
    create_table :scenarios do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.decimal :total_giving_amount, precision: 12, scale: 2

      t.timestamps
    end
  end
end
