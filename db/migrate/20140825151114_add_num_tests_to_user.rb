class AddNumTestsToUser < ActiveRecord::Migration
  def change
    add_column :users, :num_tests, :integer
  end
end
