class AddEvalBooleanToMobileSubmissions < ActiveRecord::Migration
  def change
    add_column :mobile_submissions, :evaluated, :boolean
  end
end
