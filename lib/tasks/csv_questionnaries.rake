require "csv"

namespace :data do
  task :questionnaires => :environment do

    PRE_KEYS = %i(pre_test_1 pre_test_2)
    POST_KEYS = User::POST_TEST_OPTION_SETS.keys + [:cond_specific]

    CSV.open(Rails.root.join("tmp", "csv", "questionnaires.csv"), "wb") do |csv|

      csv << (%w(user_id condition) + PRE_KEYS + POST_KEYS)

      User.where("study_phase IN ('seed', 'main')").complete.in_cur_study.order(:condition).each do |user|
        row = [user.id, user.condition]
        row.concat(PRE_KEYS.map{ |k| user.pre_test[k] })
        row.concat(POST_KEYS.map do |k|
          if k == :cond_specific
            k = user.post_test.keys.detect{ |pk| pk =~ /^#{user.condition}_/ }
            raise if k.nil?
          end
          user.post_test[k]
        end)
        csv << row
      end

    end
  end
end
