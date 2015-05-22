class AddBgTimesToMobileSubmissions < ActiveRecord::Migration
  def change
    add_column :mobile_submissions, :premeal_bg_time, :datetime
    add_column :mobile_submissions, :postmeal_bg_time, :datetime
  end
end
