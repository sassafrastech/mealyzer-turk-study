class User < ActiveRecord::Base
  ACTIVE_CONDITIONS = [1, 2, 3, 4, 5, 6, 9, 10, 11]

  CONDITION_NAMES = [
    "No feedback",
    "Compare with answer but can't revise",
    "Can compare AND revise",
    "Evaluate someone else's answer",
    "Show ratings and explanations by other users, but can't change answer",
    "Same as #5 but can change answer",
    "Every N answers, review last N answers with option to revise",
    "Same as #7 but with no option to revise",
    "Same as #2, but with bar chart instead of most popular",
    "Same as #3, but with bar chart instead of most popular",
    "Same as #6, but with expert feedback"
  ]

  REQUIRE_UNIQUE = true

  POST_TEST_OPTION_SETS = {
    :level_difficulty => :answers_difficulty,
    :confident => :answers_confidence,
    :confident_groups => :answers_confidence,
    :feedback => :answers_agree,
    :future => :answers_agree,
    :learned => :answers_agree
  }

  scope :in_phase, -> (phase) { where(study_phase: phase).where(study_id: Settings.study_id) }

  # Users that have at least one trial for the current study and given study phase
  scope :complete_in_phase, -> (phase) { in_phase(phase).where(complete: true) }

  # Users that have at least one trial for the current study and given condition
  scope :complete_in_phase_and_condition,
    -> (phase, cond) { complete_in_phase(phase).where(condition: cond) }

  serialize :pre_test
  serialize :post_test
  serialize :test_order

  before_save :score_pre_post_test
  before_create :choose_phase
  before_create :choose_condition
  before_create :set_test_order

  attr_accessor :pre_test_1, :pre_test_2, :force_condition, :force_study_phase

  # Returns the number of available meal components
  def self.max_tests
    @@max_tests ||= Meal.all_tests.size
  end

  def phase_progress
    return nil unless study_phase == "seed"
    done = self.class.complete_in_phase(study_phase).count
    "#{done}/#{Settings.seed_phase_count}"
  end

  def condition_progress
    done = self.class.complete_in_phase_and_condition(study_phase, condition).count
    "#{done}/#{Settings.max_subj_per_condition}"
  end

  def max_tests?
    num_tests >= self.class.max_tests
  end

  def next_test
    # (Meal.all_tests - completed_tests).sample
    if test_order.blank? || num_tests >= test_order.size
      raise "Test order does not have test ##{num_tests}"
    end
    test_order[num_tests]
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
    return false if answers.nil? || (answers.length < I18n.t('survey.post_test_questions').length + 1)
    self.save
  end

  private

  def choose_phase
    if force_study_phase
      self.study_phase = force_study_phase
    else
      self.study_phase = seed_phase_full? ? "main" : "seed"
    end
  end

  def seed_phase_full?
    self.class.complete_in_phase("seed").count >= Settings.seed_phase_count
  end

  def condition_full?(c)
    self.class.complete_in_phase_and_condition(study_phase, c).count < Settings.min_subj_per_condition
  end

  def choose_condition
    # If this is being accessed from the tryouts panel, we can set the condition immediately
    if force_condition
      self.condition = force_condition.to_i
    elsif study_phase == "seed"
      self.condition = 1
    else
      # Select the condition with the least number of complete users
      # (if tie, use fewest incomplete users; if still tie, use condition number).
      stats = User.select("condition, SUM(complete::int) AS complete, SUM(1 - complete::int) AS incomplete").
        in_phase("main").group(:condition).order("complete", "incomplete", :condition)
      conditions_with_no_users = ACTIVE_CONDITIONS - stats.map(&:condition)
      self.condition = conditions_with_no_users.first || stats.first.condition
    end

    self.study_id = Settings.study_id
  end

  # Choses a random non-full condition. Returns nil if all conditions are full.
  def random_condition
    non_full = ACTIVE_CONDITIONS.select do |c|
      User.complete_in_phase_and_condition(study_phase, c).count < Settings.max_subj_per_condition
    end
    non_full.sample
  end

  def completed_tests
    # Get all non-evaluation-based answers for this user.
    answers = MatchAnswer.where(:user_id => id.to_s).where(:evaluating_id => nil)

    # Convert to pairs of form [meal_id, component_name]
    answers.map{ |a| [a.meal_id, a.component_name] }
  end

  def set_test_order
    meals_by_set = Meal.enabled.group_by(&:set_num)

    # Randomize each group and expand into test pairs.
    pairs_by_set = {}
    meals_by_set.each do |set_num, meals|
      pairs_by_set[set_num] = meals.map do |m|
        m.food_components.keys.map{ |c| [m.id, c, set_num] }
      end.flatten(1).shuffle
    end
    pairs_with_no_set = pairs_by_set.delete(nil) || []

    # Distribute one pair from each numbered set into pre, main, and post bins
    pre, main, post = [], [], []
    pairs_by_set.each do |_, pairs|
      pre << pairs[0]
      main << pairs[1]
      post << pairs[2]

      # Put rest in main area
      pairs[3..-1].each do |m, c, x|
        main << [m, c, x]
      end
    end

    # Pairs with no set go in main area
    main += pairs_with_no_set

    self.test_order = pre.shuffle + main.shuffle + post.shuffle
  end

  def score_pre_post_test
    %w(pre post).each do |type|
      self.send("#{type}_test_score=",
        (scores = send("#{type}_test")).nil? ? nil : scores.values.map(&:to_i).reduce(:+))
    end
  end
end
