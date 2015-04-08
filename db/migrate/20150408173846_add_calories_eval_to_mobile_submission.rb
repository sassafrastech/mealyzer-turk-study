class AddCaloriesEvalToMobileSubmission < ActiveRecord::Migration
  def change
    add_column :mobile_submissions, :calories_eval, :integer
  end
end
