class AddTrainingToUser < ActiveRecord::Migration
  def change
    add_column :users, :training, :boolean
    add_column :users, :training_stage, :integer
  end
end
