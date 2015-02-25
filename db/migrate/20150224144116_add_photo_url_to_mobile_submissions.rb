class AddPhotoUrlToMobileSubmissions < ActiveRecord::Migration
  def change
    add_column :mobile_submissions, :photo_url, :string
  end
end
