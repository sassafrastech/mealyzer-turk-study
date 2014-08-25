class MatchAnswer < ActiveRecord::Base

  MAX_TESTS = 10

  serialize :food_groups, JSON
  serialize :food_groups_update, JSON
  serialize :answers_changed, JSON

  delegate :condition, to: :user
  delegate :num_tests, to: :user

  validate :food_groups_exist
  validate :food_groups_updated

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
    food_groups.each do |item, group_arr|
        answers[item] = ((food_groups_update[item]) == group_arr.join(" "))
    end
    self.answers_changed = answers
  end

  def increment_tests!
    self.user.num_tests = self.user.num_tests + 1
    self.user.save
  end

  def max_tests?
    num_tests >= MAX_TESTS
  end

  private

  # make sure all food groups are accounted for in answer
  def food_groups_exist
    if items.sort != food_groups.keys.sort
      errors.add(:food_groups, "must be accounted for")
    end
  end

  def food_groups_updated
    return true if (answers_changed.nil? || answers_changed.empty?)
    if food_groups_update.nil? || (food_groups.keys.length != self.food_groups_update.keys.length)
      errors.add(:food_groups_update, "must be accounted for")
    end
  end

end
