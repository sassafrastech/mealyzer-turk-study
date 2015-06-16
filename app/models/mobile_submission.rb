class MobileSubmission < ActiveRecord::Base
  THRESHOLD_PROTEIN = 5
  THRESHOLD_CARBS = 5
  THRESHOLD_FAT = 5
  THRESHOLD_FIBER = 5
  THRESHOLD_CALORIES = 5

  has_attached_file :photo, :styles => { :medium => "300x300>", :thumb => "100x100>" }, :default_url => "/images/:style/missing.png"

  validates_attachment_content_type :photo, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]

  def grade!
    update_attributes(
      :protein_grade => (protein_user - protein_eval).abs <= THRESHOLD_PROTEIN,
      :carbs_grade => (carbs_user - carbs_eval).abs <= THRESHOLD_CARBS,
      :fiber_grade => (fiber_user - fiber_eval).abs <= THRESHOLD_FIBER,
      :fat_grade => (fat_user - fat_eval).abs <= THRESHOLD_FAT,
      :calories_grade => (calories_user - calories_eval).abs <= THRESHOLD_CALORIES)
  end

end
