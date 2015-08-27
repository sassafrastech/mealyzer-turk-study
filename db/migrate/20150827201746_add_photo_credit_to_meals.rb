class AddPhotoCreditToMeals < ActiveRecord::Migration
  def change
    add_column :meals, :photo_credit, :text
    Meal.update_all(photo_credit: '"2014 Bruschetta The Larder Chiang Mai" by Takeaway - Own work. ' <<
      'Licensed under CC BY-SA 4.0 via Wikimedia Commons - ' <<
      'http://commons.wikimedia.org/wiki/File:2014_Bruschetta_The_Larder_Chiang_Mai.jpg' <<
      '#/media/File:2014_Bruschetta_The_Larder_Chiang_Mai.jpg')
  end
end
