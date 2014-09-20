require "pp"
class MatchAnswerSummarizer

  attr_reader :meal_id, :component

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
    pp "OTHER ANSWERS #{oa}"
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

  def initialize(meal_id, component)
    @meal_id = meal_id
    @component = component
  end

  def summary
    build_summary unless @summary
    @summary
  end

  def self.num_matches(answer)
    num_matches = 0
    MatchAnswer.where("meal_id = ? AND component_name = ?", answer.meal_id, answer.component_name).each do |a|
      num_matches += 1 if answer.food_groups == a.food_groups
    end
    return num_matches
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
    if all.first[1] > num_matches(answer)
      return all.first[0]
    else
      return answer.food_groups
    end
  end

  def evaluations(answer)
    @eval ||= build_evaluations(answer)
  end

  private
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
