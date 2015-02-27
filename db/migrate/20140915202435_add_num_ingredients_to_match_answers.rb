class AddNumIngredientsToMatchAnswers < ActiveRecord::Migration
  def change
    add_column :match_answers, :num_ingredients, :integer
    add_column :match_answers, :num_correct, :integer
    add_column :match_answers, :num_correct_update, :integer
  end
end
