class AddShareTokenToScenarios < ActiveRecord::Migration[8.1]
  def change
    add_column :scenarios, :share_token, :string
    add_index :scenarios, :share_token, unique: true
  end
end
