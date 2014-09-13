class ChangeUsersFormatToMatchAnswers < ActiveRecord::Migration
  def change
    execute "ALTER TABLE match_answers ALTER COLUMN user_id TYPE integer USING CAST(user_id as INTEGER)"
  end
end
