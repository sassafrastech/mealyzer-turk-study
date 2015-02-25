class CreateMobileSubmissions < ActiveRecord::Migration
  def change
    create_table :mobile_submissions do |t|
      t.string :uid
      t.text :description
      t.integer :protein_user
      t.integer :fat_user
      t.integer :carbs_user
      t.integer :fiber_user

      t.timestamps
    end
  end
end
