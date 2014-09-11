class AddFoodGroupsCorrectAllToMatchAnswer < ActiveRecord::Migration
  def change
    add_column :match_answers, :food_groups_correct_all, :text
    add_column :match_answers, :food_groups_update_correct_all, :text
  end
end
