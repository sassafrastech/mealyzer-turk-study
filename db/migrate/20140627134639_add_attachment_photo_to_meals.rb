class AddAttachmentPhotoToMeals < ActiveRecord::Migration
  def self.up
    change_table :meals do |t|
      t.attachment :photo
    end
  end

  def self.down
    drop_attached_file :meals, :photo
  end
end
