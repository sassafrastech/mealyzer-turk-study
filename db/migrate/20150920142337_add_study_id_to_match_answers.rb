class AddStudyIdToMatchAnswers < ActiveRecord::Migration
  def change
    add_column :match_answers, :study_id, :string
    execute("UPDATE match_answers SET study_id = (SELECT study_id FROM users WHERE users.id = match_answers.user_id)")
  end
end
