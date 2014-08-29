class AddChangedToMatchAnswers < ActiveRecord::Migration
  def change
    add_column :match_answers, :changed_answer, :boolean
  end
end
