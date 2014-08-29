class AddImpactToMatchAnswers < ActiveRecord::Migration
  def change
    add_column :match_answers, :impact, :integer
  end
end
