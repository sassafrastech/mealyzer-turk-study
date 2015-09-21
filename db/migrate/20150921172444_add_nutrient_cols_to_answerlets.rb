class AddNutrientColsToAnswerlets < ActiveRecord::Migration
  def change
    Meal::GROUPS.each do |g|
      add_column(:answerlets, g.downcase, :boolean, null: false, default: false)
      execute("UPDATE answerlets SET #{g.downcase} = 't' WHERE nutrients LIKE '%#{g}%'")
    end
  end
end
