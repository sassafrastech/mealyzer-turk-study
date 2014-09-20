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

    CSV.open(Rails.root.join("tmp","csv", "popular.csv"), "wb") do |csv|

      csv << ["match_answer_id", "meal_id", "component", "user_id", "condition", "user_num_correct", "user_num_correct_update","popular_answer",
        "popular_num_correct", "num_correct_with_popular", "num_correct_update_with_popular","num_ingredients", "task_num", "timestamp", "answer", "updated_answer"]

      users.each do |user|
        matches = MatchAnswer.where(:user_id => user.id)
        matches.each do |match|
          row = []
          row << match.id
          row << match.meal_id
          row << match.component_name
          row << user.id
          row << user.condition
          row << match.num_correct

          if match.num_correct_update.nil?
            row << "N/A"
          else
              row << match.num_correct_update
          end
          popular = MatchAnswerSummarizer.most_popular_at_time(match)

          if !popular.nil?
            row << popular
            ma = MatchAnswer.where('food_groups = ?', popular.to_json).first
            row << ma.num_correct
            row << match.compare_popular(popular)
            row << match.compare_update_popular(popular)
          else
            row << "N/A"
            row << "N/A"
            row << "N/A"
            row << "N/A"
          end


          row << match.num_ingredients
          row << match.task_num
          row << match.created_at
          row << match.food_groups

          if match.food_groups_update
            row << match.food_groups_update
          else
            row << "N/A"
          end

          csv << row
        end
      end

    end
  end

  task :evaluated => :environment do
    users = User.where("condition = 5 OR condition = 6").where(:study_id => 'study_1').where('num_tests = 28')

    CSV.open(Rails.root.join("tmp","csv", "evaluated.csv"), "wb") do |csv|
      csv << ["match_answer_id", "meal_id", "component", "user_id", "condition", "user_num_correct", "user_num_correct_update",
      "num_ingredients", "task_num", "timestamp", "evaluation_received_correct", "evaluation_received_incorrect",
      "evaluation_right?"]

      users.each do |user|
        matches = MatchAnswer.where(:user_id => user.id)
        matches.each do |match|
          row = []
          row << match.id
          row << match.meal_id
          row << match.component_name
          row << user.id
          row << user.condition
          row << match.num_correct
          if match.num_correct_update.nil?
            row << "N/A"
          else
              row << match.num_correct_update
          end

          row << match.num_ingredients
          row << match.task_num
          row << match.created_at
          eval = MatchAnswerSummarizer.build_evaluations_time(answer)
          row << match.evaluation_num[0]
          row << match.evaluation_num[1]
          row << match.evaluation_right
          csv << row
        end

      end

    end


  end

end
