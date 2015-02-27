class AddPreTestScoreToUser < ActiveRecord::Migration
  def change
    add_column :users, :pre_test_score, :integer
    add_column :users, :post_test_score, :integer
  end
end
