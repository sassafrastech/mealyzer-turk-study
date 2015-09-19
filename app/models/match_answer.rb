class MatchAnswer < ActiveRecord::Base

  # Ideally should be in YML
  IMPACT_SCORES = {1 => "Does not really change overall nutritional breakdown",
                   2 => "Has a moderate impact on the overall nutritional breakdown",
                   3 => "Has a significant impact on the overall nutritional breakdown"}

  before_create :increment_task_num
  before_save :evaluate_answers

  serialize :food_groups, JSON
  serialize :food_groups_update, JSON
  serialize :food_groups_correct_all, JSON
  serialize :food_groups_update_correct_all, JSON

  delegate :condition, :num_tests, to: :user, allow_nil: true
  delegate :expert_feedback, to: :meal

  validate :food_groups_exist, :food_groups_updated
  validate :explanation_when_updated, :impact_when_updated

  belongs_to :meal
  belongs_to :user

  scope :current_study, -> { includes(:user).where("users.study_id" => Settings.study_id) }
  scope :seed_phase, -> { includes(:user).where("users.study_phase" => "seed") }
  scope :for_component, -> (meal_id, component) { where("meal_id = ? AND component_name = ?", meal_id, component) }
  scope :for_same_component_as, -> (answer) { for_component(answer.meal_id, answer.component_name) }
  scope :for_users_other_than, -> (user) { where("user_id != ?", user.id) }
  scope :for_complete_users, -> { includes(:user).where("users.complete = ?", true) }
  scope :for_complete_users_other_than, -> (user) { for_users_other_than(user).for_complete_users }
  scope :valid_seed_phase, -> { current_study.seed_phase.for_complete_users }

  def self.build_for_random_meal(user)
    user_id = user.id unless user.nil?
    meal = Meal.random
    new(:meal => meal, :component_name => meal.sample_component_name, :user_id => user_id)
  end

  def self.random
    ma = nil
    loop do
      ma = MatchAnswer.first(:offset => rand(MatchAnswer.count))
      break if !ma.food_groups.nil?
    end
    return ma
  end

  def self.next(user)
    test = user.next_test
    answer = if test.nil?
      build_for_random_meal(user)
    else
      meal = Meal.find(test[0])
      new(meal: meal, component_name: test[1], user: user)
    end

    # In condition 12, we need to create a fake, anonymous answer consisting of popular
    # answers for various ingredients
    if user.condition == 12
      answer.user = nil
      answer.food_groups = meal.food_nutrition[test[1]]
    end

    answer
  end

  def self.last_five(user)
    where(user_id: user.id).order("created_at DESC").limit(5).reverse
  end

  # Returns a random answer from the seed phase of the current study with the same
  # meal and component as the given answer.
  def self.equivalent(answer)
    current_study.seed_phase.for_same_component_as(answer).sample
  end

  # Returns a copy of this answer with the appropriate evaluation fields set.
  def copy_for_eval(user)
    self.class.create(meal_id: meal_id, user_id: user.id, food_groups: food_groups,
      component_name: component_name, evaluating_id: id)
  end

  # Builds and returns answerlets for all ingredients in this answer
  def as_answerlets
    (food_groups || {}).map do |ing, nutrients|
      Answerlet.new(meal: meal, component_name: component_name, ingredient: ing, nutrients: nutrients)
    end
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
      self.changed_answer = true if food_groups_update[item].sort != group_arr.sort
    end

  end

  # Copies food group answers to food_groups_update for use in review form,
  # unless food_groups_update has already been set.
  def init_for_review
    self.food_groups_update ||= food_groups
  end


  def individual_answers(compare_food_groups)
    {}.tap do |correct_all|
      meal.food_nutrition[component_name].each do |item|
        item = item[0]
        correct_all[item] = {}
        actual_groups = meal.food_nutrition[component_name][item]
        answered_groups = compare_food_groups[item]
        Meal::GROUPS.each do |g|
          unless actual_groups.nil? || answered_groups.nil?
            correct_all[item][g] = actual_groups.include?(g) == answered_groups.include?(g) ? 'correct' : 'incorrect'
          end
        end
      end
    end
  end

  # popular is a hash of item names to groups.
  # Returns the total score of in common to popular and self.food_groups.
  def compare_popular(popular)
    score = 0
    food_groups.each do |item, groups|
      Meal::GROUPS.each do |g|
        score += 1 if groups.include?(g) == popular[item].include?(g)
      end
    end
    return score
  end

  def compare_update_popular(popular)
    score = 0
    if !food_groups_update.nil?
      food_groups_update.each do |item, groups|
        Meal::GROUPS.each do |g|
          score += 1 if groups.include?(g) == popular[item].include?(g)
        end
      end
      return score
    else
      return "N/A"
    end
  end

  def correct_for(options)
    food_groups_correct_all[options[:ingredient]][options[:nutrient]] == "correct"
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
    return if changed_answer.nil? || condition == 2
    if food_groups_update.nil? || (food_groups.keys.length != food_groups_update.keys.length)
      # Since they messed up, reset the update value to the original.
      self.food_groups_update = food_groups
      errors.add(:food_groups_update, ": all food items must have a food group selected")
    end
  end

  def explanation_when_updated
    if changed_answer && (explanation.nil? || explanation.empty?)
      errors.add(:explanation, "is required when you change your answer")
    end
  end

  def impact_when_updated
    if condition == 4 && changed_answer == true && impact.nil?
      errors.add(:impact, "is missing, please make a selection")
    end
  end

  def increment_task_num
    # User may be nil if this is a fake answer. In that case we don't need to assign a task_num
    return true if user.nil?
    if condition == 4 && evaluating_id
      self.task_type = "peer-assessment"
      self.task_num = user.num_tests
    else
      self.task_type = "primary"
      self.task_num = user.num_tests + 1
    end
    return true
  end

  def answers_match?(a1, a2)
    a1.keys.sort == a2.keys.sort && a1.all?{ |ing, nutr| a2[ing].sort == nutr.sort }
  end

  def evaluate_answers
    self.num_ingredients = food_groups.keys.length

    unless food_groups.nil?
      # overall assessment
      self.food_groups_correct = answers_match?(meal.food_nutrition[component_name], food_groups)

      answers = individual_answers(food_groups)

      # individual assessment
      self.food_groups_correct_all = answers

      values = []
      answers.values.each do |v|
        v.each_value {|value| values.push(value)}
      end

      self.num_correct = values.select{|a| a == "correct"}.length
    end

    unless food_groups_update.nil?
      # overall assessment
      self.food_groups_update_correct = answers_match?(meal.food_nutrition[component_name], food_groups_update)

      answers = individual_answers(food_groups_update)

      # individual assessment
      self.food_groups_update_correct_all = answers

      values = []
      answers.values.each do |v|
        v.each_value {|value| values.push(value)}
      end

      self.num_correct_update = values.select{|a| a == "correct"}.length
    end
    return true
  end


end
