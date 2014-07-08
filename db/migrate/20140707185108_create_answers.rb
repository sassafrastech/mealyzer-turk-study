class CreateAnswers < ActiveRecord::Migration
  def change
    create_table :answers do |t|
      t.integer :user_id
      t.integer :meal_id
      t.text :food_locations, :default => "none"
      t.text :food_names
      t.text :food_nutrition
    end
    add_index :answers, :user_id
    add_index :answers, :meal_id
  end
end
