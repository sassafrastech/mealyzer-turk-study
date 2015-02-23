class MobileSubmission < ActiveRecord::Base
  THRESHOLD_PROTEIN = 2
  THRESHOLD_CARBS = 10
  THRESHOLD_FAT = 2
  THRESHOLD_FIBER = 10

  has_attached_file :photo, :styles => { :medium => "300x300>", :thumb => "100x100>" }, :default_url => "/images/:style/missing.png"
  validates_attachment_content_type :photo, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]

  def grade!
    protein_grade = abs(protein_user - protein_eval) <= THRESHOLD_PROTEIN
    carbs_grade = abs(carbs_user - carbs_eval) <= THRESHOLD_CARBS
    fiber_grade = abs(fiber_user - fiber_eval) <= THRESHOLD_FIBER
    fat_grade = abs(fat_user - fat_eval) <= THRESHOLD_FAT
    save!
  end

end
