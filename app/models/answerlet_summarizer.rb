# Finds most popular answerlets for data in seed phase
class AnswerletSummarizer

  def nth_most_popular_for_ingredient(n, params)
    rows = Answerlet.joins(match_answer: :user).
      where("users.study_id = ?", Settings.study_id).
      where("users.study_phase = 'seed'").
      where("users.complete = 't'").
      where(params).
      group("meal_id", "component_name", "ingredient", "nutrients").
      order("meal_id, component_name, ingredient, count_all DESC, nutrients").count

    raise "No answerlets found for #{params}" if rows.empty?

    # Make sure n is within array size
    n -= 1 # Was 1-based
    n = rand(rows.keys.size) if n >= rows.keys.size

    JSON.parse(rows.keys[n][3])
  end

  # Returns top answerlets for all ingredients for current study seed phase
  def top_5_for_all_ingredients
    result = Answerlet.joins(match_answer: :user).
      where("users.study_id = ?", Settings.study_id).
      where("users.study_phase = 'seed' OR users.study_phase = 'explain'").
      where("users.complete = 't'").
      group("meal_id", "component_name", "ingredient", "nutrients", "study_phase").
      order("meal_id, component_name, ingredient, count_all DESC, nutrients, study_phase DESC").count

    result = result.map do |data, count|
      {meal_id: data[0], component_name: data[1], ingredient: data[2],
        nutrients: JSON.parse(data[3]).map{ |n| Meal::GRP_ABBRVS[n] }.join,
        study_phase: data[4], count: count}
    end

    result = result.group_by{ |h| h.slice(:meal_id, :component_name, :ingredient) }.each do |mci, data|
      data.group_by{ |h| h[:nutrients] }.each do |nutrients, data2|
        data2[0][:ans_count] = data2[0].delete(:count)
        data2[0].delete(:study_phase)
        if data2[1]
          data2[0][:exp_count] = data2[1][:count]
          data.delete(data2[1])
        end
      end
    end
  end
end
