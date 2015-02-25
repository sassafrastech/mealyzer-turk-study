class AddExplanationsToMobileSubmissions < ActiveRecord::Migration
  def change
    add_column :mobile_submissions, :protein_explain, :text
    add_column :mobile_submissions, :fat_explain, :text
    add_column :mobile_submissions, :carbs_explain, :text
    add_column :mobile_submissions, :fiber_explain, :text
  end
end
