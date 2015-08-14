class AddStudyPhaseToUsers < ActiveRecord::Migration
  def change
    add_column :users, :study_phase, :string, null: false, index: true, default: "seed"
  end
end
