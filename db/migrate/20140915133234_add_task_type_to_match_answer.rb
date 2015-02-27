class AddTaskTypeToMatchAnswer < ActiveRecord::Migration
  def change
    add_column :match_answers, :task_type, :string
  end
end
