class ChangeFormatInMobileSubmission < ActiveRecord::Migration
  def change
    change_column :mobile_submissions, :calories_grade, 'boolean USING CAST(calories_grade AS boolean)'
  end
end
