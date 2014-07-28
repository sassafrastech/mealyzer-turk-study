class Meal < ActiveRecord::Base
  %w(:food_locations, :food_options, :food_nutrition, :food_components).each {|column| serialize column, JSON}

  GROUPS = ["Protein", "Fat", "Carbohydrate", "Fiber"]

  has_attached_file :photo, :default_url => "/images/:style/missing.png"
  validates_attachment_content_type :photo, :content_type => /\Aimage\/.*\Z/

  def rand_component
    c = JSON.parse(food_components)
    @rand_component = @rand_component || c.slice(c.keys.sample)
  end
end
