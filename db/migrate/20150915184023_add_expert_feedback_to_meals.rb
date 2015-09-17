class AddExpertFeedbackToMeals < ActiveRecord::Migration
  def change
    add_column :meals, :expert_feedback, :text
  end
end
