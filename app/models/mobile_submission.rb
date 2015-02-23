class MobileSubmission < ActiveRecord::Base
  THRESHOLD_PROTEIN = 2
  THRESHOLD_CARBS = 10
  THRESHOLD_FAT = 2
  THRESHOLD_FIBER = 10

  has_attached_file :photo, :styles => { :medium => "300x300>", :thumb => "100x100>" }, :default_url => "/images/:style/missing.png"
  validates_attachment_content_type :photo, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]

  def grade!
    Rails.logger.debug("GRADING!!!!!!!!!!!!!!!!!")
    update_attributes(:protein_grade => (protein_user - protein_eval).abs <= THRESHOLD_PROTEIN,
      :carbs_grade => (carbs_user - carbs_eval).abs <= THRESHOLD_CARBS,
      :fiber_grade => (fiber_user - fiber_eval).abs <= THRESHOLD_FIBER,
      :fat_grade => (fat_user - fat_eval).abs <= THRESHOLD_FAT)

  end

end
