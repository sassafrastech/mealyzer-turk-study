class AddGradesToMobileSubmissions < ActiveRecord::Migration
  def change
    add_column :mobile_submissions, :protein_grade, :boolean
    add_column :mobile_submissions, :fat_grade, :boolean
    add_column :mobile_submissions, :carbs_grade, :boolean
    add_column :mobile_submissions, :fiber_grade, :boolean
  end
end
