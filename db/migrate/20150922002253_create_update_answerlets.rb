class CreateUpdateAnswerlets < ActiveRecord::Migration
  def up
    MatchAnswer.all.each do |ma|
      if ma.food_groups_update.is_a?(Hash) && ma.answerlets.where(kind: 'update').empty?
        ma.as_answerlets(kind: 'update').each(&:save)
      end
    end
  end
end
