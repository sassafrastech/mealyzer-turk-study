class AddDisabledToMeals < ActiveRecord::Migration
  def change
    add_column :meals, :disabled, :boolean, default: false, null: false
  end
end
