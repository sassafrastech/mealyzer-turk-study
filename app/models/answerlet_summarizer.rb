# Finds most popular answerlets for data in seed phase
class AnswerletSummarizer

  def ensure_answerlets
    if Answerlet.current_study.empty?
      Answerlet.for_phase("seed").each(&:save)
    end
  end

  def nth_most_popular_for_ingredient(n, params)
    rows = Answerlet.joins(:match_answer).current_study.where(params).
      group("meal_id, component_name, ingredient, nutrients").
      order("count_all DESC").count

    raise "No answerlets found for #{params}" if rows.empty?

    # Make sure n is within array size
    n -= 1 # Was 1-based
    n = rand(rows.keys.size) if n >= rows.keys.size

    JSON.parse(rows.keys[n][3])
  end

  def top_5_for_all_ingredients
    result = Answerlet.joins(:match_answer).current_study.group("meal_id", "component_name", "ingredient", "nutrients").
      order("meal_id, component_name, ingredient, count_all DESC").count

    result = result.map do |data, count|
      {meal_id: data[0], component_name: data[1], ingredient: data[2],
        nutrients: JSON.parse(data[3]).map{ |n| Meal::GRP_ABBRVS[n] }.join, count: count}
    end

    result = result.group_by{ |h| h.slice(:meal_id, :component_name, :ingredient) }
  end
end
