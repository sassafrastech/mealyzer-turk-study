class MobileSubmissionsController < ApplicationController
  protect_from_forgery :except => :create
  before_action :authenticate_user!,  :except => :edit

  def create
    params[:mobile_submission] = JSON.parse(params[:mobile_submission])

    @mobile_submission = MobileSubmission.create(params.require(:mobile_submission).permit!)

    @mobile_submission.photo = params.permit(:file)[:file]

    if @mobile_submission.save!
      # need to save photo url after paperclip
      @mobile_submission.photo_url = @mobile_submission.photo.url(:medium)
      @mobile_submission.user_id = current_user.id
      @mobile_submission.save!
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
    Rails.logger.debug("updating the evalution")
    @mobile_submission = MobileSubmission.find(params[:id])
    params[:mobile_submission][:evaluated] = true
    @mobile_submission.update_attributes(params.require(:mobile_submission).permit!)
    @mobile_submission.grade!
    Rails.logger.debug("about to find the user")
    @user = User.find(@mobile_submission.user_id)
    Rails.logger.debug("the user is #{@user}")
    Rails.logger.debug("Sending a PN using the token #{@user.token}")
    PushNotification.send(@user.token)
  end

  def index
    # get all submissions for a particular user that have not been evaluated yet
    @submitted = MobileSubmission.where(:user_id => current_user.id).where(:evaluated => nil)
    @evaluated = MobileSubmission.where(:user_id => current_user.id).where(:evaluated => true)
    @all = {:submitted => @submitted, :evaluated => @evaluated}
    respond_to do |format|
      format.json { render json: @all }
    end
  end

  def show
    @meal = MobileSubmission.find(params[:id])
    respond_to do |format|
      format.json { render json: @meal}
    end
  end
end
