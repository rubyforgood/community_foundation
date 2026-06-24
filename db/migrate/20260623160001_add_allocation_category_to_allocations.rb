class AddAllocationCategoryToAllocations < ActiveRecord::Migration[8.1]
  def change
    add_reference :allocations, :allocation_category, foreign_key: true
    change_column_null :allocations, :option, true
  end
end
