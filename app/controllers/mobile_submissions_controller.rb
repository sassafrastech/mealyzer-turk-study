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
      PushNotification.send(@mobile_submission.user.push_notification_token)
    end
  end

  private

  def mobile_submissions_parameters
    params.require(:mobile_submission).permit(:protein_eval, :carbs_eval, :fiber_eval, :fat_eval, :calories_eval,
      :protein_explain, :fat_explain, :carbs_explain, :fiber_explain, :calories_explain)
  end
end