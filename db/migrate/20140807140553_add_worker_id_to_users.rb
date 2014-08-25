class AddWorkerIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :workerId, :string
    add_column :users, :assignmentId, :string
    add_column :users, :hitId, :string
  end
end
