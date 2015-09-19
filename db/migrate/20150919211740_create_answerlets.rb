class CreateAnswerlets < ActiveRecord::Migration
  def change
    create_table :answerlets do |t|
      t.string :study_id, null: false, index: true
      t.integer :meal_id, null: false, index: true, foreign_key: true
      t.string :component_name, null: false
      t.string :ingredient, null: false
      t.string :nutrients, null: false

      t.timestamps
    end

    add_index :answerlets, [:meal_id, :component_name, :ingredient]
  end
end
