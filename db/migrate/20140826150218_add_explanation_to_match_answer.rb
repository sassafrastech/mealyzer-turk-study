class AddExplanationToMatchAnswer < ActiveRecord::Migration
  def change
    add_column :match_answers, :explanation, :text
  end
end
