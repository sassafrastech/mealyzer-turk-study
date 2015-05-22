class AddDiabetesFieldsToMobileSubmission < ActiveRecord::Migration
  def change
    add_column :mobile_submissions, :premeal_bg, :integer
    add_column :mobile_submissions, :insulin, :integer
    add_column :mobile_submissions, :reminder, :boolean
    add_column :mobile_submissions, :postmeal_bg, :integer
  end
end
