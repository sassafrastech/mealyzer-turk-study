require "pp"
require "csv"

namespace :data do
  task :tests_csv => :environment do
    users = User.complete_in_cur_study.where("pre_test != 'NULL' AND post_test != 'NULL'")

    CSV.open(Rails.root.join("tmp", "csv", "survey_results.csv"), "wb") do |csv|

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

  # Returns a list of answer popularity, grouped by meal, component, and ingredient
  task answerlet_popularity: :environment do

    grouped = Answerlet.for_phase("seed").group_by(&:identity)

    CSV.open(Rails.root.join("tmp", "csv", "answerlet_popularity.csv"), "wb") do |csv|

      csv << %w(meal_id meal_name component ingredient answer count correct)

      grouped.sort_by{ |a, v| [a, -v.size] }.each do |a, v|
        csv << [
          a.meal.id,
          a.meal.name,
          a.component_name,
          a.ingredient,
          a.ntrnts,
          v.size,
          a.correct? ? "x" : ""
        ]
      end
    end
  end

  task nutrient_popularity_by_ingredient: :environment do
    grouped = Answerlet.for_phase("seed").group_by(&:meal_comp_ing)

    CSV.open(Rails.root.join("tmp", "csv", "nutrient_popularity_by_ingredient.csv"), "wb") do |csv|

      csv << %w(meal_id meal_name component ingredient) + Meal::GRP_ABBRVS.values + %w(correct)

      grouped.sort_by{ |mci, _| mci }.each do |_, answerlets|
        # Compute tallies of each nutient for all answerlets in this group.
        tallies = ActiveSupport::OrderedHash[*Meal::GROUPS.map{ |n| [n, 0] }.flatten]
        answerlets.each do |a|
          a.nutrients.each do |n|
            tallies[n] += 1
          end
        end

        a = answerlets.first
        csv << [a.meal.id, a.meal.name, a.component_name, a.ingredient] +
          tallies.values + [a.correct_answerlet.ntrnts]
      end
    end
  end

  task :most_popular_for_user => :environment do
    users = User.complete_in_cur_study.where("condition = 2 OR condition = 3")

    CSV.open(Rails.root.join("tmp", "csv", "popular.csv"), "wb") do |csv|

      csv << ["match_answer_id", "meal_id", "component", "user_id", "condition", "user_num_correct",
        "user_num_correct_update","popular_answer", "popular_num_correct", "num_correct_with_popular",
        "num_correct_update_with_popular","num_ingredients", "task_num", "timestamp", "answer", "updated_answer"]

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
    users = User.complete_in_cur_study.where("condition = 5 OR condition = 6")

    CSV.open(Rails.root.join("tmp", "csv", "evaluated.csv"), "wb") do |csv|
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
          eval = MatchAnswerSummarizer.build_evaluations_time(match)
          row << eval[:correct]
          row << eval[:incorrect]

          # If the answer is actually right...
          if match.num_correct == (match.num_ingredients * 4)
            # and they say it is incorrect, they are wrong!
            if eval[:correct] < eval[:incorrect]
              row << "False"
              # if they say it is right, they are right!
            elsif eval[:correct] > eval[:incorrect]
              row << "True"
              # they are the same
            else
              row << "Same"
            end
            # If the answer is actually wrong...
          else
             # and they say it is incorrect, they are right!
            if eval[:correct] < eval[:incorrect]
              row << "True"
              # if they say it is right, they are wrong!
            elsif eval[:correct] > eval[:incorrect]
              row << "False"
              # they are the same
            else
              row << "Same"
            end
          end

          csv << row
        end
      end
    end
  end

  # Just for new conditions 2 and 3
  task :learning_gains => :environment do
    File.new("tmp/csv/learning_gains.csv", "w")

    users = User.complete_in_cur_study.where("condition = 2 OR condition = 3")

    CSV.open(Rails.root.join("tmp", "csv", "learning_gains.csv"), "wb") do |csv|
      csv << ["user_id", "condition", "study_id", "learning_pre", "learning_post", "learning_post_update", "learning_gains_diff", "learning_gains_diff_update", "learning_pre_popular", "learning_post_popular", "learning_gains_diff_popular"]

      users.each do |user|
        row = []

        answers_first_five = MatchAnswer.where(:user_id => user.id).where('task_num < 6').limit(5).all
        answers_last_five = MatchAnswer.where(:user_id => user.id).where('task_num > 23 AND task_num < 29').limit(5).all


        row << user.id
        row << user.condition
        row << user.study_id

        # learning pre
        learning_pre = MatchAnswerSummarizer.accuracy(answers_first_five)
        row << learning_pre

        # learning post
        learning_post = MatchAnswerSummarizer.accuracy(answers_last_five)
        row << learning_post

        learning_post_update = nil

        if user.condition == 3
          learning_post_update = MatchAnswerSummarizer.accuracy_updated(answers_last_five)
          row << learning_post_update
        else
          row << "N/A"
        end

        # learning gains diff
        row << learning_post - learning_pre

        if learning_post_update
          row << learning_post_update - learning_pre
        else
          row << "N/A"
        end


        learning_pre_popular = MatchAnswerSummarizer.accuracy_popular(answers_first_five)
        row << learning_pre_popular

        learning_post_popular = MatchAnswerSummarizer.accuracy_popular(answers_last_five)
        row << learning_post_popular

        learning_post_popular_update = nil
        if user.condition == 3
            learning_post_popular_update = MatchAnswerSummarizer.accuracy_popular_updated(answers_last_five)
            row << learning_post_popular_update
        else
          row << "N/A"
        end

        row << learning_post_popular - learning_pre_popular

        if learning_post_popular_update
          row << learning_post_popular_update - learning_pre_popular
        else
          row << "N/A"
        end

        csv << row

      end
    end
  end
end
