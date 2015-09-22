# Finds most popular answerlets for data in seed phase
class AnswerletSummarizer

  DECISIONS = %w(no tie yes)

  def least_explained_for_ingredient(max_rank, params)
    # Get top N answerlets from seed phase.
    ans_rows = Answerlet.joins(match_answer: :user).
      where("users.study_id = ?", Settings.study_id).
      where("users.study_phase = 'seed'").
      where("users.complete = 't'").
      where(params).
      group("meal_id", "component_name", "ingredient", "nutrients").
      order("meal_id, component_name, ingredient, count_all DESC, nutrients").
      limit(max_rank).count

    raise "No answerlets found for #{params}" if ans_rows.empty?

    # Get explanation counts for each.
    nutrients = ans_rows.map{ |r, _| r[3] }

    exp_rows = Answerlet.joins(match_answer: :user).
      select("meal_id, component_name, ingredient, nutrients").
      select("SUM(CASE WHEN users.complete = 't' THEN 1 ELSE 0 END) AS comp_count").
      select("SUM(CASE WHEN users.complete = 'f' THEN 1 ELSE 0 END) AS incomp_count").
      where("users.study_id = ?", Settings.study_id).
      where("users.study_phase = 'explain'").
      where(params).
      where(nutrients: nutrients).
      group("meal_id", "component_name", "ingredient", "nutrients").
      order("meal_id, component_name, ingredient, comp_count, incomp_count, nutrients").to_a

    if exp_rows.empty?
      JSON.parse(nutrients.first)
    else
      exp_rows.first.nutrients
    end
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

  # For a given meal_id, component_name, and ingredient, returns a hash of form:
  # {
  #   "Carbohydrate" => { decision: "yes", count: 14, total: 21 },
  #   "Fat" => { decision: "tie", count: 10, total: 20 },
  #   ...
  # }
  def most_popular_per_nutrient(params)
    params["match_answers.meal_id"] = params.delete(:meal_id) if params[:meal_id]
    params["match_answers.component_name"] = params.delete(:component_name) if params[:component_name]

    result = Answerlet.joins(match_answer: :user)
    Meal::LC_GROUPS.each do |g|
      result = result.select("SUM(CASE WHEN #{g} = 't' THEN 1 ELSE 0 END) AS #{g}_yes")
    end
    result = result.select('COUNT(*) AS total')

    result = result.where(params).
      where("users.study_id = ?", Settings.study_id).
      where("users.study_phase = 'seed'").
      where("users.complete = 't'").to_a.first.attributes

    Hash[*Meal::LC_GROUPS.map do |g|
      decision = DECISIONS[(result["#{g}_yes"] <=> result["total"].to_f / 2) + 1]
      count = decision == "yes" ? result["#{g}_yes"] : result["total"] - result["#{g}_yes"]
      [g.capitalize, { decision: decision, count: count, total: result["total"] }]
    end.flatten]
  end
end
