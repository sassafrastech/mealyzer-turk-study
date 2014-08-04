class AddComponentNameToMatchAnswers < ActiveRecord::Migration
  def change
    add_column :match_answers, :component_name, :string
  end
end
