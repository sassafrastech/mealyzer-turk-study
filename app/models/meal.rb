class Meal < ActiveRecord::Base
  %w(:food_locations, :food_options, :food_nutrition).each {|column| serialize column, JSON}

  has_attached_file :photo, :default_url => "/images/:style/missing.png"
  validates_attachment_content_type :photo, :content_type => /\Aimage\/.*\Z/
end
