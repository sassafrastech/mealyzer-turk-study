require "pp"
class MatchAnswerSummarizer

  attr_reader :meal_id, :component, :current_user

  def self.other_answers_at_time(answer)
    other_answers = {}
    answers = MatchAnswer.where("meal_id = ? AND component_name = ?", answer.meal_id, answer.component_name).where('created_at < ?',answer.created_at).where(
      "food_groups != 'NULL'")
    answers.each do |a|
      if a.food_groups != answer.food_groups
        other_answers[a.food_groups] ||= 0
        other_answers[a.food_groups] += 1
      end
    end
    oa = other_answers.sort_by {|food_groups, num| num}
    oa.reverse
  end

  def self.most_popular_at_time(answer)
    all = other_answers_at_time(answer)
    if all.empty?
      return nil
    else
      if all.first[1] > num_matches(answer)
        return all.first[0]
      else
        return answer.food_groups
      end
    end
  end

  def self.num_matches(answer)
    num_matches = 0
    MatchAnswer.where("meal_id = ? AND component_name = ?", answer.meal_id, answer.component_name).each do |a|
      num_matches += 1 if answer.food_groups == a.food_groups
    end
    return num_matches
  end

  # determines accuracy of initial try
  def self.accuracy(answers)
    accuracy = 0
    answers.each do |a|
      accuracy += (a.num_correct.to_f / (a.num_ingredients * 4))
    end
    return accuracy
  end

  def self.accuracy_updated(answers)
    accuracy = 0
    answers.each do |a|
      correct = a.num_correct_update.nil? ? a.num_correct : a.num_correct_update
      accuracy += (a.num_correct_update.to_f / (a.num_ingredients * 4))
    end
    return accuracy
  end

  def self.accuracy_popular(answers)
    # first fill in popular column
    score = 0
    answers.each do |a|
      accuracy_popular = a.compare_popular(most_popular_at_time(a))
      score += accuracy_popular.to_f / (a.num_ingredients * 4)
    end
    return score
  end

  def self.accuracy_popular_updated(answers)
    # first fill in popular column
    score = 0
    answers.each do |a|
      compare = a.num_correct_update.nil? ? "compare_popular" : "compare_update_popular"
      accuracy_popular = a.send(compare, most_popular_at_time(a))
      score += accuracy_popular.to_f / (a.num_ingredients * 4)
    end
    return score

  end

  def self.build_evaluations_time(answer)
    evals = {id: answer.id, correct: 0, incorrect: 0, explanations: []}
    ma = MatchAnswer.where("food_groups = ? AND evaluating_id IS NOT NULL", answer.food_groups.to_json).where("created_at < answer.created_at")
    if !ma.nil?
      ma.each do |a|
         if a.changed_answer
          evals[:incorrect] += 1
          unless a.explanation.nil?
            evals[:explanations].push(a.explanation)
          end
        else
          evals[:correct] += 1
        end
      end
      evals[:length] = ma.length
      return evals
    else
      return nil
    end
  end

  def initialize(meal_id, component, current_user)
    @meal_id = meal_id
    @component = component
    @current_user = current_user
  end

  def summary
    build_summary unless @summary
    @summary
  end

  def num_matches(answer)
    num_matches = 0
    MatchAnswer.where("meal_id = ? AND component_name = ?", answer.meal_id, answer.component_name).each do |a|
      num_matches += 1 if answer.food_groups == a.food_groups
    end
    return num_matches
  end

  # Counts how often each food group was chosen for each component item.
  # Normalizes to value between 0 and 1.
  # Returns ordered hash of form: {
  #   "Salmon" => {"Protein" => .13, "Fat" => .36, "Carbohydrate" => .46, "Fiber" => .05},
  #   "Oil" => {"Protein" => .25, "Fat" => .25, "Carbohydrate" => .25, "Fiber" => .25}
  # }
  # Returns nil if no other answers for this component.
  def tallies_by_component
    return @tallies_by_component if @tallies_by_component

    answers = MatchAnswer.for_component(meal_id, component).for_users_other_than(current_user)
    return nil if answers.empty?

    @tallies_by_component = {}.tap do |result|
      answers.each do |answer|
        answer.food_groups.each do |item, groups|
          result[item] ||= { "Protein" => 0, "Fat" => 0, "Carbohydrate" => 0, "Fiber" => 0 }
          groups.each do |group|
            result[item][group] += 1
          end
        end
      end

      # Normalize
      result.each do |component_name, tallies|
        total = tallies.values.inject(0){ |sum, i| sum += i }
        tallies.keys.each do |k|
          result[component_name][k] /= total.to_f
        end
      end
    end
  end

  def other_answers(answer)
    other_answers = {}
    MatchAnswer.where("meal_id = ? AND component_name = ?", meal_id, component).each do |a|
      if a.food_groups != answer.food_groups
        other_answers[a.food_groups] ||= 0
        other_answers[a.food_groups] += 1
      end
    end
    oa = other_answers.sort_by {|food_groups, num| num}
    oa.reverse
  end

  def most_popular(answer)
    all = other_answers(answer)
    if all.any? && all.first[1] > num_matches(answer)
      return all.first[0]
    else
      return answer.food_groups
    end
  end

  def evaluations(answer)
    @eval ||= build_evaluations(answer)
  end

  def increment(item, groups)
    @summary[item] ||= {}
    @summary[item][groups] ||= 0
    @summary[item][groups] += 1
  end

  def build_summary
    @summary = {}
    MatchAnswer.where("meal_id = ? AND component_name = ?", meal_id, component).each do |answer|
      (answer.food_groups || {}).each do |item, groups|
        increment(item,groups)
      end
    end
  end

  def build_evaluations(answer)
    evals = {id: answer.id, correct: 0, incorrect: 0, explanations: []}
    ma = MatchAnswer.where("food_groups = ? AND evaluating_id IS NOT NULL", answer.food_groups.to_json)
    if !ma.nil?
      ma.each do |a|
         if a.changed_answer
          evals[:incorrect] += 1
          unless a.explanation.nil?
            evals[:explanations].push(a.explanation)
          end
        else
          evals[:correct] += 1
        end
      end
      evals[:length] = ma.length
      return evals
    else
      return nil
    end
  end
end
