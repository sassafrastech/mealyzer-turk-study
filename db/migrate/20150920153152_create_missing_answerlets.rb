class CreateMissingAnswerlets < ActiveRecord::Migration
  def change
    MatchAnswer.where("NOT EXISTS (SELECT * FROM answerlets WHERE match_answers.id = answerlets.match_answer_id)").each do |ma|
      ma.as_answerlets.each(&:save)
    end
  end
end
