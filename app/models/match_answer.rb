class MatchAnswer < ActiveRecord::Base

  serialize :food_groups, JSON
  serialize :food_groups_update, JSON
  serialize :answers_changed, JSON

  delegate :condition, :num_tests, to: :user

  validate :food_groups_exist
  validate :food_groups_updated
  validate :explanation_when_updated

  belongs_to :meal
  belongs_to :user

  def self.build_for_random_meal(user)
    user_id = user.id unless user.nil?
    meal = Meal.random
    new(:meal => meal, :component_name => meal.sample_component_name, :user_id => user_id)
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
    answers = {}
    # if food groups is empty
    if food_groups_update.nil?
      return
    end
    food_groups.each do |item, group_arr|
        answers[item] = ((food_groups_update[item]) == group_arr.join(" "))
    end
    self.answers_changed = answers
  end

  private

  # make sure all food groups are accounted for in answer
  def food_groups_exist
    if food_groups.nil?
      errors.add(:food_groups, "cannot be empty")
    else
       errors.add(:food_groups, "must be accounted for") if items.sort != food_groups.keys.sort
    end
  end

  def food_groups_updated
    return true if (answers_changed.nil? || answers_changed.empty?)
    if food_groups_update.nil? || (food_groups.keys.length != self.food_groups_update.keys.length)
      errors.add(:food_groups_update, "must be accounted for")
    end
  end

  def explanation_when_updated
    pp "validating explanation when updated: food_groups_update and result is: #{food_groups_update == food_groups}"
    pp "explanation.nil?: #{explanation.nil?}"
    if (food_groups_update == food_groups) && explanation.nil?
      errors.add(:explanation, "is required when you change your answer")
    end
  end

end

