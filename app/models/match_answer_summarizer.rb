require "ostruct"

class MatchAnswerSummarizer
  extend OpenStruct

  def summary
    build_summary unless @summary
    @summary


    # {chicken: {"3":[protein, fat], "4":[carb, fiber], "9":[protein, carb, fiber]}, "asparagus": {}

    # food_groups: {"honey chicken"=>{"chicken"=>["protein", "fat"], "honey"=>["fat"], "butter"=>["fat"]}}, created_at: "2014-07-29 16:10:43", updated_at: "2014-07-29 16:10:43", sample_component: nil>

  end

  private
    def increment(item, groups)
      @summary[item] ||= {}
      @summary[item][groups] ||= 0
      @summary[item][groups] += 1
    end

    def build_summary
      @summary = {}
      MatchAnswer.where(:meal_id => meal_id).each do |answer|
        (answer.food_groups[component] || {}).each do |item, groups|
          increment(item,groups)
        end
      end
    end


end
