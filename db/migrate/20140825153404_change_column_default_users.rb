class ChangeColumnDefaultUsers < ActiveRecord::Migration
  def change
    change_column_default :users, :num_tests, 0
  end
end
