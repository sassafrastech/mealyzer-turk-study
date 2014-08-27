class RemoveAnswersChangedFromMatchAnswers < ActiveRecord::Migration
  def change
    remove_column :match_answers, :answers_changed
  end
end
