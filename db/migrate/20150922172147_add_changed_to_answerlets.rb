class AddChangedToAnswerlets < ActiveRecord::Migration
  def change
    add_column :answerlets, :modified, :boolean
    add_index :answerlets, :modified

    execute("UPDATE answerlets SET modified = 'f' WHERE kind = 'update'")
    execute("UPDATE answerlets a SET modified = 't' WHERE EXISTS " <<
      "(SELECT * FROM answerlets a2 WHERE a2.match_answer_id = a.match_answer_id AND a2.ingredient = a.ingredient " <<
        " AND a2.kind = 'original' AND a2.nutrients != a.nutrients)")
  end
end
