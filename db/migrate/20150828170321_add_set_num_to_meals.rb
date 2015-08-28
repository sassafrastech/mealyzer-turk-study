class AddSetNumToMeals < ActiveRecord::Migration
  def change
    add_column :meals, :set_num, :integer
    add_index :meals, :set_num
  end
end
