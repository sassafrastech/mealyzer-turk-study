class MatchAnswer < ActiveRecord::Base

  # Ideally should be in YML
  IMPACT_SCORES = {1 => "Does not really change overall nutritional breakdown",
                   2 => "Has a moderate impact on the overall nutritional breakdown",
                   3 => "Has a significant impact on the overall nutritional breakdown"}

  serialize :food_groups, JSON
  serialize :food_groups_update, JSON

  delegate :condition, :num_tests, to: :user

  validate :food_groups_exist, :food_groups_updated
  validate :explanation_when_updated, :impact_when_updated

  belongs_to :meal
  belongs_to :user

  def self.build_for_random_meal(user)
    user_id = user.id unless user.nil?
    meal = Meal.random
    new(:meal => meal, :component_name => meal.sample_component_name, :user_id => user_id)
  end

  def self.random
    MatchAnswer.first(:offset => rand(MatchAnswer.count))
  end

  def self.copy_for_eval(obj, user)
    MatchAnswer.create(:meal_id => obj.meal_id, :user_id => user.id, :food_groups => obj.food_groups,
      :component_name => obj.component_name, :evaluating_id => obj.id)
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

  def build_answers_changed!
    self.changed_answer = false

    return if food_groups_update.nil? || (food_groups.keys.length != food_groups_update.keys.length)

    food_groups.each do |item, group_arr|
      self.changed_answer = true if food_groups_update[item].join(" ") != group_arr.join(" ")
    end

  end

  private
  def food_groups_exist
    if food_groups.nil?
      errors.add(:food_groups, "cannot be empty")
    else
       errors.add(:food_groups, "must be accounted for") if items.sort != food_groups.keys.sort
    end
  end

  def food_groups_updated
    return if (changed_answer.nil?) || condition == 2
    if food_groups_update.nil? || (food_groups.keys.length != food_groups_update.keys.length)
      errors.add(:food_groups_update, ": all food items must have a food group selected")
    end
  end

  def explanation_when_updated
    if (changed_answer == true) && (explanation.nil? || explanation.empty?)
      errors.add(:explanation, "is required when you change your answer")
    end
  end

  def impact_when_updated
    if user.condition == 4 && changed_answer == true && impact.nil?
      errors.add(:impact, "is missing, please make a selection")
    end
  end

end

