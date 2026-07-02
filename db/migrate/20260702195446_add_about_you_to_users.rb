class AddAboutYouToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :background, :text
    add_column :users, :family, :text
    add_column :users, :formative_experiences, :text
  end
end
