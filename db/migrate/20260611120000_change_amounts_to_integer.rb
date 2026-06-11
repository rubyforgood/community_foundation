class ChangeAmountsToInteger < ActiveRecord::Migration[8.1]
  def change
    change_column :scenarios, :total_giving_amount, :integer
    change_column :allocations, :amount, :integer
  end
end
