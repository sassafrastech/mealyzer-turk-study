class AddStudyIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :study_id, :string
  end
end
