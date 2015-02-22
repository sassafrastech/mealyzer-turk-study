class MobileSubmissionsController < ApplicationController
  protect_from_forgery :except => :create

  def create
    uid = params.permit(:uid)
    new_params = params.permit(:other)
    Rails.logger.debug(new_params)

    new_params = {:uid => uid}
    Rails.logger.debug(new_params)
    @mobile_submission = MobileSubmission.create(new_params)
    @mobile_submission.photo = params.permit(:file)

    if @mobile_submission.save!
      SubmissionMailer.nutrition_request(@mobile_submission).deliver
      render :nothing => true, :status => 200, :content_type => 'text/html'
    else
      render :nothing => true, :status => 500, :content_type => 'text/html'
    end
  end

  def edit
    @mobile_submission = MobileSubmission.find(params[:id])
  end

  def update
    @mobile_submission = MobileSubmission.find(params[:id])
    params[:mobile_submission][:evaluated] = true
    @mobile_submission.update_attributes(params.require(:mobile_submission).permit!)
    # could send push notification here, but we will just poll currently
  end

  def index
    # get all submissions for a particular user that have not been evaluated yet
    @submitted = MobileSubmission.where(:uid => params[:id]).where(:evaluated => nil).all
    @evaluated = MobileSubmission.where(:uid => params[:id]).where(:evaluated => true).all
    @all = {:submitted => @submitted, :evaluated => @evaluated}
    Rails.logger.debug(@all)
    respond_to do |format|
      format.html
      format.json { render json: @all }
    end

  end

end