# Handles web-based meal operations.
class MobileSubmissionsController < ApplicationController
  def edit
    @mobile_submission = MobileSubmission.find(params[:id])
  end

  def update
    @mobile_submission = MobileSubmission.find(params[:id])
    @mobile_submission.evaluated = true
    @mobile_submission.update_attributes(mobile_submissions_parameters)
    @mobile_submission.grade!

    unless Rails.env.development? || Rails.env.test?
      PushNotification.send(@mobile_submission.user.token)
    end

    render nothing: true
  end

  private

  def mobile_submissions_parameters
    params.require(:mobile_submission).permit(:protein_user, :fat_user, :carbs_user,
                                              :fiber_user, :created_at, :photo_file_name,
                                              :photo_content_type, :photo_file_size, :photo_updated_at,
                                              :protein_eval, :carbs_eval, :fiber_eval, :fat_eval,
                                              :evaluated, :meal, :protein_grade,
                                              :fat_grade, :carbs_grade, :fiber_grade,
                                              :protein_explain, :fat_explain, :carbs_explain,
                                              :fiber_explain, :photo_url, :calories_user,
                                              :calories_grade, :calories_explain, :calories_eval,
                                              :premeal_bg, :insulin, :reminder,
                                              :postmeal_bg, :premeal_bg_time, :postmeal_bg_time
                                              )
  end
end