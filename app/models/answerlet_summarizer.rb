# Finds most popular answerlets for data in seed phase
class AnswerletSummarizer

  def ensure_answerlets
    if Answerlet.current_study.empty?
      Answerlet.for_phase("seed").each(&:save)
    end
  end

  def nth_most_popular_for_ingredient(n, params)
    ensure_answerlets
    params[:meal_id] = params.delete(:meal).id

    rows = Answerlet.current_study.where(params).group(params.keys << "nutrients").
      order("count_all DESC").count

    raise "No answerlets found for #{params}" if rows.empty?

    # Make sure n is within array size
    n -= 1 # Was 1-based
    n = rand(rows.keys.size) if n >= rows.keys.size

    JSON.parse(rows.keys[n][3])
  end
end
