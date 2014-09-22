require "pp"
class User < ActiveRecord::Base
  before_create :choose_condition

  MAX_CONDITION = 40
  MIN_CONDITION = 40

  NUM_CONDITIONS = 8

  MAX_TESTS = Meal.all_tests.length

  REQUIRE_UNIQUE = true
  STUDY_ID = "study_2"

  POST_TEST_OPTION_SETS = {:level_difficulty => :answers_difficulty,  :confident => :answers_confidence, :confident_groups => :answers_confidence,
    :feedback => :answers_agree, :future => :answers_agree, :learned => :answers_agree}

  serialize :pre_test
  serialize :post_test

  attr_accessor :pre_test_1, :pre_test_2

  def unique?
    # should be unique across all studies
    unique = (User.where(:workerId => workerId).where("num_tests > ?", 0).first == nil)

    Rails.logger.debug("NUM TESTS #{num_tests}")
    Rails.logger.debug("Unique?? #{unique}")

    if !User::REQUIRE_UNIQUE
      return true
    else
      return unique || (num_tests < User::MAX_TESTS)
    end

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

  def assign_pre_test(answers)
    return false if answers.nil? || answers[:pre_test_1].nil? || answers[:pre_test_2].nil?
    self.pre_test = answers
    self.save
  end

  def assign_post_test(answers)
    self.post_test = answers
    return false if answers.nil? || (answers.length < I18n.t('survey.post_test_questions').length+1)
    self.save
  end

  private

  def choose_condition
    #first need to make sure we have a min number of 1
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
    elsif User.where(condition: 8).where(study_id: STUDY_ID).where("num_tests > ?", 0).count < MIN_CONDITION
      self.condition = 8
    else
      self.condition = random_condition
    end

    self.study_id = STUDY_ID

    self.condition = 3

  end

  def random_condition
    1.upto(NUM_CONDITIONS) do |c|
      return c if User.where(condition: c).where(:study_id => STUDY_ID).where("num_tests > ?", 0).count <= MAX_CONDITION
    end
    return nil
  end

  def completed_tests
    completed = []
    answers = MatchAnswer.where(:user_id => id.to_s).where(:evaluating_id => nil)
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
