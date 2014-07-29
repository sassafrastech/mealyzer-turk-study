class AddSampleComponentToMatchAnswer < ActiveRecord::Migration
  def change
    add_column :match_answers, :sample_component, :text
  end
end
