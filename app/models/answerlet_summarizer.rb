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
      select("meal_id, component_name, ingredient, nutrients").
      select("SUM(CASE WHEN users.study_phase = 'seed' THEN 1 ELSE 0 END) AS ans_count").
      select("SUM(CASE WHEN users.study_phase = 'explain' THEN 1 ELSE 0 END) AS exp_count").
      where("users.study_id = ?", Settings.study_id).
      where("users.study_phase = 'seed' OR users.study_phase = 'explain'").
      where("users.complete = 't'").
      group("meal_id", "component_name", "ingredient", "nutrients").
      order("meal_id, component_name, ingredient, ans_count DESC, nutrients")

    result.map{ |r| r.attributes.with_indifferent_access }.
      group_by{ |h| h.slice(:meal_id, :component_name, :ingredient) }
  end
end
