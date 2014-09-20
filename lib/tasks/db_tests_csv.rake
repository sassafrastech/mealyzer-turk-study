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
end
