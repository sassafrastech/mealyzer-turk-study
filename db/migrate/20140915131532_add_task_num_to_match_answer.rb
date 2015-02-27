class AddTaskNumToMatchAnswer < ActiveRecord::Migration
  def change
    add_column :match_answers, :task_num, :integer
  end
end
