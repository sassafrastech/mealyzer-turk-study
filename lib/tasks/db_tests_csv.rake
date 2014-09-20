require "pp"
require "csv"

namespace :db do
  task :tests_csv => :environment do
    users = User.where(:study_id => 'study_1').where("pre_test != 'NULL' AND post_test != 'NULL'")

    CSV.open(Rails.root.join("tmp","csv", "survey_results.csv"), "wb") do |csv|

      csv << ["user_id", "pre_test_1", "pre_test_2", "post_test_level_difficulty", "post_test_confident_correct",
        "post_test_confident_food_groups", "post_test_time_consuming", "post_test_additional_info", "post_test_learned",
        "post_test_condition_specific"]

      users.each do |user|
        row = []
        row << user.id
        user.pre_test.each{|a| row << a.last.to_i}
        user.post_test.each{|a| row << a.last.to_i}
        pp "ROW: #{row}"
        csv << row
      end
    end
  end

  task :most_popular_for_user => :environment do
    users = User.where("condition = 2 OR condition = 3").where(:study_id => 'study_1').where('num_tests = 28')
    pp "users #{users.inspect}"

    CSV.open(Rails.root.join("tmp","csv", "popular.csv"), "wb") do |csv|

      csv << ["match_answer_id", "meal_id", "component", "user_id", "condition", "popular_answer",
        "popular_num_correct", "num_ingredients", "task_num", "timestamp"]

      users.each do |user|
        matches = MatchAnswer.where(:user_id => user.id)
        matches.each do |match|
          row = []
          pp "THE MATCH #{match.inspect}"
          row << match.id
          row << match.meal_id
          row << match.component_name
          row << user.id
          row << user.condition
          popular = MatchAnswerSummarizer.most_popular_at_time(match)
          if !popular.nil?
            row << popular
            pp "The popular one: #{popular.to_json}"
            ma = MatchAnswer.where('food_groups = ?', popular.to_json).first
            row << ma.num_correct
          else
            row << "NULL"
          end
          row << match.num_ingredients
          row << match.task_num
          row << match.created_at
          pp "ROW: #{row}"
          csv << row
        end
      end

    end



  end
end
