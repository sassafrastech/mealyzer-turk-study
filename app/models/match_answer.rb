class MatchAnswer < ActiveRecord::Base

  serialize :food_groups, JSON

  validate :food_groups_exist

  belongs_to :meal

  def self.build_for_random_meal
    meal = Meal.random
    new :meal => meal, :component_name => meal.sample_component_name
  end

  def item_has_group?(item, group)
    return false if food_groups.nil?
    (food_groups[item] || []).include?(group)
  end

  def items
    meal.items_for_component(component_name)
  end

  def location
    meal.location_for_component(component_name)
  end

  private

  # make sure all food groups are accounted for in answer
  def food_groups_exist
    if items.sort != food_groups.keys.sort
      errors.add(:food_groups, "must be accounted for")
    end
  end

end
