class AddFoodComponentsToMeals < ActiveRecord::Migration
  def change
    add_column :meals, :food_components, :text
  end
end
