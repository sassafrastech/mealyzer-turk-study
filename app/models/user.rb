class User < ActiveRecord::Base
  before_create :choose_condition

  MAX_SUBJ_PER_CONDITION = 40
  MIN_SUBJ_PER_CONDITION = 40

  ACTIVE_CONDITIONS = [1, 2, 3, 5, 6, 7, 9, 10]

  CONDITION_NAMES = [
    "No feedback",
    "Compare with answer but can't revise",
    "Can compare AND revise",
    "Can compare, revise, AND assess size of change you made",
    "Pretend that sent your answer to others and rated it as correct/incorrect, with explanation, but can't change answer",
    "Same as #5 but can change answer",
    "Evaluate someone else's answer",
    "Can see how evaluated you, can change answer, and asked to estimate how change was",
    "Same as #2, but with bar chart instead of most popular",
    "Same as #3, but with bar chart instead of most popular"
  ]

  # How many pre- and post-control trails each user should take.
  PRE_POST_CONTROL_COUNT = 1

  # For some conditions, user can reevaluate answers ever N answers. This is N. Should be an even divisor of
  # self.max_tests.
  REEVAL_INTERVAL = 5

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

  # Returns the number of available meal components
  def self.max_tests
    @@max_tests ||= Meal.all_tests.size
  end

  def unique?
    # should be unique across all studies
    unique = (User.where(:workerId => workerId).where("num_tests > ?", 0).first == nil)

    if !User::REQUIRE_UNIQUE
      return true
    else
      return unique || (num_tests < self.class.max_tests)
    end
  end

  def max_tests?
    num_tests >= self.class.max_tests
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
    # Get all non-evaluation-based answers for this user.
    answers = MatchAnswer.where(:user_id => id.to_s).where(:evaluating_id => nil)

    # Convert to pairs of form [meal_id, component_name]
    answers.map{ |a| [a.meal_id, a.component_name] }
  end
end
