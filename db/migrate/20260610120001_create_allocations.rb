class CreateAllocations < ActiveRecord::Migration[8.1]
  def change
    create_table :allocations do |t|
      t.references :scenario, null: false, foreign_key: true
      t.string :type, null: false
      t.string :option, null: false
      t.integer :percentage
      t.decimal :amount, precision: 12, scale: 2
      t.text :note

      t.timestamps
    end
  end
end
