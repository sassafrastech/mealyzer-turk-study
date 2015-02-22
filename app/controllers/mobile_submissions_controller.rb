class MobileSubmissionsController < ApplicationController
  protect_from_forgery :except => :create

  def create
    uid = params.permit(:uid)
    new_params = params.permit(:other)
    Rails.logger.debug(new_params)

    new_params = {:uid => uid}
    Rails.logger.debug(new_params)
    mobile_submission = MobileSubmission.create(new_params)
    mobile_submission.photo = params.permit(:file)


    if mobile_submission.save!
      render :nothing => true, :status => 200, :content_type => 'text/html'
      # send email request to admin
    else
      render :nothing => true, :status => 500, :content_type => 'text/html'
    end


  end

end