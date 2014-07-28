class Meal < ActiveRecord::Base
  %w(food_locations food_options food_nutrition food_components).each {|column| serialize column, JSON}

  GROUPS = ["Protein", "Fat", "Carbohydrate", "Fiber"]

  has_attached_file :photo, :default_url => "/images/:style/missing.png"
  validates_attachment_content_type :photo, :content_type => /\Aimage\/.*\Z/

  def self.random
    Meal.first
    #(:offset => rand(Meal.count))
  end

  def sample_component
    mc = food_components.slice(food_components.keys.sample)
    @sample_component ||= MealComponent.new(mc.keys[0], mc.values[0])
  end

  def answer_in_meal?(match, food_item, nutrition)

    if match.food_groups.nil? || match.food_groups[sample_component.name].nil? ||  match.food_groups[sample_component.name][food_item].nil?
      Rails.logger.debug("Returnign false because there are some nil values in match")
      return false
    else
      m = match.food_groups[sample_component.name][food_item].includes?(nutrition)
      Rails.logger.debug("returning the match #{m}")
    end

  end

end
