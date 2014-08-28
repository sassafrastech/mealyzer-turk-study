class AddEvaluatingToMatchAnswers < ActiveRecord::Migration
  def change
    add_column :match_answers, :evaluating_id, :integer
    add_index :match_answers, :evaluating_id
  end
end
