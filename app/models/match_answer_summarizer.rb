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


end
