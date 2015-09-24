require "pp"
require "csv"

KEY_INGS = ActiveSupport::OrderedHash[
  beans: ["Black turtle beans", "Pinto beans", "Beans"],
  avo: ["Avocado"],
  mozza: ["Fresh mozarella"],
  nuts: ["Peanut butter", "Almonds"],
  corn: ["Corn"]
]

namespace :data do
  task :main_phase => :environment do
    CSV.open(Rails.root.join("tmp", "csv", "main_phase.csv"), "wb") do |csv|

      headers = %w(user_id condition accuracy_base accuracy_last_5 feedback_correctness)
      KEY_INGS.each do |i, _|
        headers.concat(["#{i}_accuracy_base", "#{i}_accuracy_last_5"])
        Meal::GRP_ABBRVS.values.each do |g|
          headers.concat(["#{i}_fdbk_#{g.downcase}"])
        end
        headers.concat(["#{i}_learn_no_ties", "#{i}_learn_w_ties"])
      end

      csv << headers

      User.where("study_phase IN ('seed', 'main')").complete.in_cur_study.order(:condition).each do |user|
        csv << [
          user.id,
          user.condition,
          accuracy(user, "pre-control"),
          accuracy(user, "post-control"),
          overall_feedback_correctness(user)
        ].concat(KEY_INGS.map{ |_, ing_set| key_ingredient_data(user, ing_set) }.flatten)
      end
    end
  end

  def key_ingredient_data(user, ing_set)
    [
      key_ingredient_accuracy(user, ing_set, 'pre-control'),
      key_ingredient_accuracy(user, ing_set, 'post-control'),
      key_ingredient_feedback_correctness_array(user, ing_set),
      key_ingredient_learning_gain(user, ing_set, ties: false),
      key_ingredient_learning_gain(user, ing_set, ties: true)
    ]
  end

  def accuracy(user, task_type)
    # This should always yield 5 answers
    answers = user.match_answers.where(task_type: task_type)
    raise unless answers.count == 5

    answers.map(&:num_correct).sum.to_f / (answers.map(&:num_ingredients).sum * 4) * 100
  end

  def key_ingredient_accuracy(user, ing_set, task_type)
    # Find answers with the ingredient
    answer, ing = find_key_ingredient_answer(user, ing_set, task_type)
    num_correct = answer.food_groups_correct_all[ing].map{ |nutrient, result| result == "correct" ? 1 : 0 }.reduce(:+)
    num_correct.to_f / 4 * 100
  end

  def find_key_ingredient_answer(user, ing_set, task_type)
    answers = user.match_answers.where(task_type: task_type).select{ |a| (a.food_groups.keys & ing_set).present? }
    raise if answers.size != 1
    [answers.first, (answers.first.food_groups.keys & ing_set).first]
  end

  def overall_feedback_correctness(user)
    summarizer = AnswerletSummarizer.new
    answers = user.match_answers.where(task_type: "primary")
    if [3,13,14].include?(user.condition)
      scores = answers.map{ |a| feedback_correctness(user.condition, a) }
      scores.sum{ |s| s[0] }.to_f / scores.sum{ |s| s[1] } * 100
    else
      nil
    end
  end

  def key_ingredient_feedback_correctness_array(user, ing_set)
    correctness = key_ingredient_feedback_correctness(user, ing_set)
    Meal::GROUPS.sort.map{ |nutrient| correctness[nutrient] }
  end

  def key_ingredient_feedback_correctness(user, ing_set)
    answer, ing = find_key_ingredient_answer(user, ing_set, "primary")
    feedback_correctness(user.condition, answer, ingredient: ing, return: :per_nutrient)
  end

  def feedback_correctness(condition, match_answer, options = {})
    @feedback_correctness ||= {}
    params = { condition: condition, match_answer_id: match_answer.id }

    if @feedback_correctness[params]
      score, boxes, per_nutrient = @feedback_correctness[params]

    else
      summarizer = AnswerletSummarizer.new
      correct = match_answer.meal.food_nutrition[match_answer.component_name]

      if condition == 3
        feedback = summarizer.most_popular_nutrients_seed_phase_for_all_ingredients(match_answer)
      else
        feedback = summarizer.correction_stats_for_all_ingredients(match_answer)
      end

      score, boxes, per_nutrient = 0, 0, {}
      feedback.each do |ingredient, stats|
        next if options[:ingredient] && ingredient != options[:ingredient]
        corr_nutrients = correct[ingredient]
        fbk_nutrients = stats.each do |nutrient, info|
          if info[:decision] == "tie"
            score += 0.5
            per_nutrient[nutrient] = 0.5
          elsif info[:decision] == "yes" && corr_nutrients.include?(nutrient)
            score += 1
            per_nutrient[nutrient] = 1
          elsif info[:decision] == "no" && !corr_nutrients.include?(nutrient)
            score += 1
            per_nutrient[nutrient] = 1
          else
            per_nutrient[nutrient] = 0
          end
          boxes += 1
        end
      end
      @feedback_correctness[params] = [score, boxes, per_nutrient]
    end

    if options[:return] == :per_nutrient
      per_nutrient
    else
      [score, boxes]
    end
  end

  def num_correct(corr_nutrients, sub_nutrients)
    (sub_nutrients & corr_nutrients).size + (4 - corr_nutrients.size)
      - (sub_nutrients - corr_nutrients).size
  end

  def key_ingredient_learning_gain(user, ing_set, options)
    pre_incorrect = key_ingredient_result_with_task_type(user, ing_set, 'pre-control', 'incorrect')

    # Get feedback correctness for primary phase. Get all nutrients with correct feedback.
    fdbk_correctness = key_ingredient_feedback_correctness(user, ing_set)
    fdbk_correct = fdbk_correctness.select{ |nutrient, score| score == 1 || options[:ties] && score == 0.5 }.keys

    post_correct = key_ingredient_result_with_task_type(user, ing_set, 'post-control', 'correct')

    (pre_incorrect & fdbk_correct & post_correct).size
  end

  def key_ingredient_result_with_task_type(user, ing_set, task_type, result)
    answer, ing = find_key_ingredient_answer(user, ing_set, task_type)
    answer.food_groups_correct_all[ing].map{ |nutrient, r| r == result ? nutrient : nil }.compact
  end
end
