class AddFieldsToAnswerlet < ActiveRecord::Migration
  def change
    Answerlet.delete_all
    add_column :answerlets, :match_answer_id, :integer, null: false, index: true, foreign_key: true
    remove_column :answerlets, :study_id
    remove_column :answerlets, :meal_id
    remove_column :answerlets, :component_name
  end
end
