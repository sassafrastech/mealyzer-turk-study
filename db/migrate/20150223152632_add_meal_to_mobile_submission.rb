class AddMealToMobileSubmission < ActiveRecord::Migration
  def change
    add_column :mobile_submissions, :meal, :string
  end
end
