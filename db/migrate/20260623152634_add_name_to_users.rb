class AddNameToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :name, :string
  end
end
