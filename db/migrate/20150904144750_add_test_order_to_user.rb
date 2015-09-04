class AddTestOrderToUser < ActiveRecord::Migration
  def change
    add_column :users, :test_order, :text
  end
end
