class CreateMatchAnswers < ActiveRecord::Migration
  def change
    create_table :match_answers do |t|
      t.integer :meal_id
      t.string :user_id
      t.text :food_groups

      t.timestamps
    end
    add_index :match_answer, :meal_id
  end
end
