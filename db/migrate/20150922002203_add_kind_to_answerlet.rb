class AddKindToAnswerlet < ActiveRecord::Migration
  def change
    add_column :answerlets, :kind, :string, default: 'original', null: false
    add_index :answerlets, :kind
  end
end
