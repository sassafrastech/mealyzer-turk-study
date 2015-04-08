class AddCaloriesToMobileSubmission < ActiveRecord::Migration
  def change
    add_column :mobile_submissions, :calories_user, :integer
    add_column :mobile_submissions, :calories_grade, :integer
    add_column :mobile_submissions, :calories_explain, :text
  end
end
