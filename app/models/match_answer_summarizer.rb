require "pp"
class MatchAnswerSummarizer

  attr_reader :meal_id, :component

  def initialize(meal_id, component)
    @meal_id = meal_id
    @component = component
  end

  def summary
    build_summary unless @summary
    @summary
  end

  def num_matches(answer)
    num_matches = 0
    MatchAnswer.where("meal_id = ? AND component_name = ?", meal_id, component).each do |a|
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
    Rails.logger.debug("OTHER ANSWERS #{oa.reverse}")

  end

  def evaluations(answer)
    build_evaluations(answer)
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
    evals = {id: answer.id, correct: 0, incorrect: 0, reasons: []}
    ma = MatchAnswer.where(:evaluating_id => answer.id)
    if !ma.nil?
      ma.each do |a|
         if a.changed_answer
          evals[:correct] += 1
        else
          evals[:incorrect] += 1
          evals[:explanations].push(a.explanation)
        end
      end
      evals[:length] = ma.length
      return evals
    else
      return nil
    end
  end

end
