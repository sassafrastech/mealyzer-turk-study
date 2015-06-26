class TidyUsersTable < ActiveRecord::Migration
  def change
    remove_column :users, :name
    remove_column :users, :nickname
    remove_column :users, :training
    remove_column :users, :training_stage
    rename_column :users, :token, :push_notification_token
  end
end
