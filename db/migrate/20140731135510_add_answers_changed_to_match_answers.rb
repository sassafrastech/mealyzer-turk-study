class AddAnswersChangedToMatchAnswer < ActiveRecord::Migration
  def change
    add_column :match_answers, :answers_changed, :text
  end
end
