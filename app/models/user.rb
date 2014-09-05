class User < ActiveRecord::Base
  before_create :choose_condition

  MAX_CONDITION = 2
  MIN_CONDITION = 2

  NUM_CONDITIONS = 4

  MAX_TESTS = 2
  #Meal.all_tests.length

  def max_tests?
    num_tests >= MAX_TESTS
  end

  def next_test
    (Meal.all_tests - completed_tests).sample
  end

  # move to user
  def increment_tests!
    self.num_tests += 1
    self.save
  end

  private

  def choose_condition
    # first need to make sure we have a min number of #1
    if User.where(condition: 1).count < MIN_CONDITION
      self.condition = 1
    elsif User.where(condition: 2).count < MIN_CONDITION
      self.condition = 2
    elsif User.where(condition: 4).count < MIN_CONDITION
      self.condition = 4
    elsif
      self.condition = random_condition
    end

  end

  def random_condition
    1.upto(NUM_CONDITIONS) do |c|
      return c if User.where(condition: c).count < MAX_CONDITION
    end
    return nil
  end

  def completed_tests
    completed = []
    answers = MatchAnswer.where(:user_id => id.to_s)
    if answers.nil?
      return nil
    else
      answers.each do |a|
        completed.push([a.meal_id, a.component_name])
      end
      return completed
    end
  end


end
