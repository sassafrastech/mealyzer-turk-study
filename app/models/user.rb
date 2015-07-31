class User < ActiveRecord::Base
  before_create :choose_condition

  MAX_SUBJ_PER_CONDITION = 40
  MIN_SUBJ_PER_CONDITION = 40

  ACTIVE_CONDITIONS = [1, 2, 3, 4, 5, 6, 7, 8]

  MAX_TESTS = Meal.all_tests.length

  REQUIRE_UNIQUE = true
  STUDY_ID = "study_3"

  POST_TEST_OPTION_SETS = {:level_difficulty => :answers_difficulty,  :confident => :answers_confidence, :confident_groups => :answers_confidence,
    :feedback => :answers_agree, :future => :answers_agree, :learned => :answers_agree}

  # Users that have at least one trial for the current study and given condition
  scope :non_empty_in_condition,
    -> (num) { where(condition: num).where(study_id: STUDY_ID).where("num_tests > ?", 0) }

  serialize :pre_test
  serialize :post_test

  attr_accessor :pre_test_1, :pre_test_2, :force_condition

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
    # If this is being accessed from the tryouts panel, we can set the condition immediately
    if force_condition
      self.condition = force_condition.to_i
    else
      # Assign user to first condition not yet at minimum.
      ACTIVE_CONDITIONS.each do |c|
        if User.non_empty_in_condition(c).count < MIN_SUBJ_PER_CONDITION
          self.condition = c
          break
        end
      end
      self.condition = nil
      # If all conditions have reached minimum, assign a random one.
      self.condition = random_condition if condition.blank?
    end

    self.study_id = STUDY_ID
  end

  # Choses a random non-full condition. Returns nil if all conditions are full.
  def random_condition
    ACTIVE_CONDITIONS.select{ |c| User.non_empty_in_condition(c).count < MAX_SUBJ_PER_CONDITION }.sample
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
