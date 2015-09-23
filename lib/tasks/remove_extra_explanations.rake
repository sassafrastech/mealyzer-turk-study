namespace :data do
  task :remove_extra_explanations => :environment do
    to_remove = []

    AnswerletSummarizer.new.top_5_for_all_ingredients.each do |mci, data|
      data.each_with_index do |d, i|
        d[:exp_ids].reject!(&:nil?)

        # If no answers at all, throw all away
        # If answer 6 or above, throw all away
        # Else keep first 5
        p mci
        p d[:exp_ids]
        extra = d[:ans_count] == 0 || i >= 5 ? d[:exp_ids] : (d[:exp_ids][5..-1] || [])

        Answerlet.where(match_answer_id: extra, ingredient: mci["ingredient"],
          nutrients: d["nutrients"].to_json).delete_all
      end
    end
  end
end
