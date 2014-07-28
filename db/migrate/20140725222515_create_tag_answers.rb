class CreateTagAnswers < ActiveRecord::Migration
  def change
    create_table :tag_answers do |t|
      t.integer :user_id
      t.integer :meal_id
      t.text :food_locations

      t.timestamps
    end
    add_index :tag_answers, :user_id
    add_index :tag_answers, :meal_id
  end
end
