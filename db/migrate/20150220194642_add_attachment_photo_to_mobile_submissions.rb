class AddAttachmentPhotoToMobileSubmissions < ActiveRecord::Migration
  def self.up
    change_table :mobile_submissions do |t|
      t.attachment :photo
    end
  end

  def self.down
    drop_attached_file :mobile_submissions, :photo
  end
end
