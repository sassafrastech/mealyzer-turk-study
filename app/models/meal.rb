class Meal < ActiveRecord::Base
  %w(food_locations food_options food_nutrition food_components).each {|column| serialize column, JSON}

  GROUPS = ["Protein", "Fat", "Carbohydrate", "Fiber"]

  has_attached_file :photo, :default_url => "/images/:style/missing.png"
  validates_attachment_content_type :photo, :content_type => /\Aimage\/.*\Z/

  def self.random
    Meal.first(:offset => rand(Meal.count))
  end

  def sample_component_name
    food_components.keys.sample
  end

  def items_for_component(name)
    food_components[name]
  end

end
