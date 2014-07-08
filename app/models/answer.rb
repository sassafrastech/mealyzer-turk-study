class Answer < ActiveRecord::Base
  validates_presence_of :food_locations, :meal_id, :user_id
end