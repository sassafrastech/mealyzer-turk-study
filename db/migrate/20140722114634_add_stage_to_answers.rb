class AddStageToAnswers < ActiveRecord::Migration
  def change
    add_column :answers, :stage, :string
  end
end
