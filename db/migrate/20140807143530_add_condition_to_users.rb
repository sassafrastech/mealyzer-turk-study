class AddConditionToUsers < ActiveRecord::Migration
  def change
    add_column :users, :condition, :integer
  end
end
