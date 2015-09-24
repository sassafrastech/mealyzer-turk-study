class User < ActiveRecord::Base
  CONDITION_NAMES = [
    "1: No feedback",
    "2: Can compare with most popular community answer but can't revise",
    "3: Can compare with most popular community answer and revise",
    "4: Evaluate someone else's answer",
    "5: Show ratings and explanations by other users, but can't change answer",
    "6: Same as #5 but can change answer",
    "7: Every N answers, review last N answers with option to revise",
    "8: Same as #7 but with no option to revise",
    "9: Same as #2, but with bar chart instead of most popular",
    "10: Same as #3, but with bar chart instead of most popular",
    "11: Same as #6, but with expert feedback",
    "12: Explanation gathering",
    "13: Per-nutrient comparison to most popular answers",
    "14: Per-nutrient comparison to most popular answers, with tallies"
  ]

  REQUIRE_UNIQUE = true

  SEED_CONDITION = 1
  EXPLAIN_CONDITION = 12
  MAIN_CONDITIONS = [3, 10, 11, 13, 14]
  SUBGROUPS = 5

  POST_TEST_OPTION_SETS = {
    :level_difficulty => :answers_difficulty,
    :confident => :answers_confidence,
    :confident_groups => :answers_confidence,
    :feedback => :answers_agree,
    :future => :answers_agree,
    :learned => :answers_agree
  }

  has_many :match_answers

  scope :in_cur_study, -> { where(study_id: Settings.study_id) }
  scope :in_phase, -> (phase) { where(study_phase: phase).in_cur_study }
  scope :complete, -> { where(complete: true) }

  # Users that have at least one trial for the current study and given study phase
  scope :complete_in_phase, -> (phase) { in_phase(phase).where(complete: true) }

  scope :complete_in_cur_study, -> { where(complete: true).in_cur_study }

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

  # Select the field value with the least number of complete users
  # (if tie, use fewest incomplete users; if still tie, use field number).
  def self.choose_best(field, options)
    stats = User.select("#{field}, COUNT(*) AS ttl").
      in_phase(options[:phase]).where(field => options[:all]).group(field).order("ttl", field)
    with_no_users = options[:all] - stats.map(&field)

    if options[:max]
      full = User.select("#{field}, COUNT(*) AS ttl").
        in_phase(options[:phase]).where(field => options[:all]).
        where(complete: true).
        group(field).order("ttl", field).having("COUNT(*) >= ?", options[:max]).map(&field)
    else
      full = []
    end

    with_no_users.first || (stats.map(&field) - full).first
  end

  def phase_progress
    return nil unless study_phase == "seed"
    done = self.class.complete_in_phase(study_phase).count
    "#{done}/#{Settings.seed_phase_count}"
  end

  def condition_progress
    self.class.complete_in_phase_and_condition(study_phase, condition).count
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
      self.study_phase = if !seed_phase_full?
        "seed"
      elsif !explain_phase_full?
        "explain"
      else
        "main"
      end
    end
  end

  def seed_phase_full?
    self.class.complete_in_phase("seed").count >= Settings.seed_phase_count
  end

  def explain_phase_full?
    self.class.complete_in_phase("explain").count >= Settings.explain_phase_count
  end

  def choose_condition
    # If this is being accessed from the tryouts panel, we can set the condition immediately
    if force_condition
      self.condition = force_condition.to_i
    elsif study_phase == "seed"
      self.condition = SEED_CONDITION
    elsif study_phase == "explain"
      self.condition = EXPLAIN_CONDITION
      self.subgroup = self.class.choose_best(:subgroup, phase: "explain", all: (1..SUBGROUPS).to_a)
    else
      self.condition = self.class.choose_best(:condition, phase: "main",
        all: MAIN_CONDITIONS, max: Settings.max_subj_per_condition)
    end

    self.study_id = Settings.study_id
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
