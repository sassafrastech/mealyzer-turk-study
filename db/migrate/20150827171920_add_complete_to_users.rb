class AddCompleteToUsers < ActiveRecord::Migration
  def change
    add_column :users, :complete, :boolean, null: false, default: false
    add_index :users, :complete
  end
end
