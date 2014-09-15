require "pp"
class User < ActiveRecord::Base
  before_create :choose_condition

  MAX_CONDITION = 4
  MIN_CONDITION = 4

  NUM_CONDITIONS = 6

  MAX_TESTS = Meal.all_tests.length

  REQUIRE_UNIQUE = false
  STUDY_ID = "pilot3"

  def unique?
    # should be unique across all studies
    User.where(:workerId => workerId).where("num_tests > ?", 0).first == nil
  end

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
    if User.where(condition: 1).where(study_id: STUDY_ID).where("num_tests > ?", 0).count < MIN_CONDITION
      self.condition = 1
    elsif User.where(condition: 2).where(study_id: STUDY_ID).where("num_tests > ?", 0).count < MIN_CONDITION
      self.condition = 2
    elsif User.where(condition: 3).where(study_id: STUDY_ID).where("num_tests > ?", 0).count < MIN_CONDITION
      self.condition = 3
    elsif User.where(condition: 4).where(study_id: STUDY_ID).where("num_tests > ?", 0).count < MIN_CONDITION
      self.condition = 4
    elsif User.where(condition: 5).where(study_id: STUDY_ID).where("num_tests > ?", 0).count < MIN_CONDITION
      self.condition = 5
    elsif User.where(condition: 6).where(study_id: STUDY_ID).where("num_tests > ?", 0).count < MIN_CONDITION
      self.condition = 6
    elsif User.where(condition: 7).where(study_id: STUDY_ID).where("num_tests > ?", 0).count < MIN_CONDITION
      self.condition = 7
    else
      self.condition = random_condition
    end

    self.condition = 7

  end

  def random_condition
    1.upto(NUM_CONDITIONS) do |c|
      return c if User.where(condition: c).where(:study_id => STUDY_ID).where("num_tests > ?", 0).count <= MAX_CONDITION
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
