class AddEvalFieldsToMobileSubmissions < ActiveRecord::Migration
  def change
    add_column :mobile_submissions, :protein_eval, :integer
    add_column :mobile_submissions, :carbs_eval, :integer
    add_column :mobile_submissions, :fiber_eval, :integer
    add_column :mobile_submissions, :fat_eval, :integer
  end
end
