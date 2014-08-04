class AddFoodGroupsUpdateToMatchAnswer < ActiveRecord::Migration
  def change
    add_column :match_answers, :food_groups_update, :text
  end
end
