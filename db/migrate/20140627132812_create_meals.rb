class CreateMeals < ActiveRecord::Migration
  def change
    create_table :meals do |t|
      t.string :name, :default => "Meal"
      t.text :food_locations
      t.text :food_options
      t.text :food_nutrition

      t.timestamps
    end
  end
end
