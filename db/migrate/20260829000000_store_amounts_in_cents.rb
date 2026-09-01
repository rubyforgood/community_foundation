class StoreAmountsInCents < ActiveRecord::Migration[8.1]
  def up
    rename_column :scenarios, :total_giving_amount, :total_giving_amount_cents
    rename_column :allocations, :amount, :amount_cents

    execute "UPDATE scenarios SET total_giving_amount_cents = total_giving_amount_cents * 100"
    execute "UPDATE allocations SET amount_cents = amount_cents * 100"
  end

  def down
    execute "UPDATE scenarios SET total_giving_amount_cents = total_giving_amount_cents / 100"
    execute "UPDATE allocations SET amount_cents = amount_cents / 100"

    rename_column :scenarios, :total_giving_amount_cents, :total_giving_amount
    rename_column :allocations, :amount_cents, :amount
  end
end
