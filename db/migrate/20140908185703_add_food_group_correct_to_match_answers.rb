class AddFoodGroupCorrectToMatchAnswers < ActiveRecord::Migration
  def change
    add_column :match_answers, :food_groups_correct, :boolean
    add_column :match_answers, :food_groups_update_correct, :boolean
  end
end
