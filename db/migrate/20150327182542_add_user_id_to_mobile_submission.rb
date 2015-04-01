class AddUserIdToMobileSubmission < ActiveRecord::Migration
  def change
    add_column :mobile_submissions, :user_id, :integer
    add_index :mobile_submissions, :user_id
  end
end
