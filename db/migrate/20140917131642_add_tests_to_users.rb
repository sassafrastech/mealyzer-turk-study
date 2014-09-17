class AddTestsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :pre_test, :text
    add_column :users, :post_test, :text
  end
end
