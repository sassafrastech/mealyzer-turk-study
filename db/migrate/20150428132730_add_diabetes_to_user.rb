class AddDiabetesToUser < ActiveRecord::Migration
  def change
    add_column :users, :diabetes, :boolean
  end
end
