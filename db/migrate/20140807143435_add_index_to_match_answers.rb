class AddIndexToMatchAnswers < ActiveRecord::Migration
  def change
    add_index :match_answers, :user_id
  end
end
