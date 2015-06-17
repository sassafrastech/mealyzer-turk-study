class MobileSubmissionsController < ApplicationController
  protect_from_forgery :except => :create
  before_action :authenticate_user!,  :except => :edit

  def create
    params[:mobile_submission] = JSON.parse(params[:mobile_submission])
    @mobile_submission = MobileSubmission.create(mobile_submission_params)
    load_photo
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
    @mobile_submission = MobileSubmission.find(params[:id])
    @mobile_submission.evaluated = true unless params[:user_update]
    @mobile_submission.update_attributes(mobile_submissions_parameters)
    @mobile_submission.grade! unless params[:user_update]
    @user = User.find(@mobile_submission.user_id)
    send_mobile_submissions
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

  def send_mobile_submissions
    if !(Rails.env.development? || Rails.env.test?)
      PushNotification.send(@user.token)
    end
    render :nothing => true, :status => 200, :content_type => 'text/html'    
  rescue => e
    render :nothing => true, :status => 500, :content_type => 'text/html'    
  end

  def load_photo
    if params[:mock_request].present?
      @mobile_submission.photo = load_photo_from_server
    else
      @mobile_submission.photo = params.permit(:file)[:file]
    end
  end

  def load_photo_from_server
    file_path = File.join(Rails.root.to_s, 'app/assets/images', 'kabobs.jpg')
    File.new(file_path, 'r')
  rescue => e
    Rails.logger.debug "File not accessible: #{e}"
  end
end
