require "pp"
class UsersController < ApplicationController

  def new
    # If workerId is given, they have accepted the HIT. So find/create the user.
    if params[:workerId]
      @user = User.find_by(workerId: params[:workerId])

      # If user is present, they must have zero tests, otherwise they are not unique.
      if @user.present?
        if @user.num_tests > 0
          @hidden = true
          flash[:error] = "Oops! We are unable to offer you this HIT because we need unique Turkers. Thank you for your interest!"
        else
          @disabled = false
        end
      else
        @user = User.create(params.permit(:assignmentId, :workerId, :hitId, :force_condition, :force_study_phase))
        if @user.condition.nil?
          @hidden = true
          flash[:error] = "We apologize, but the study is now full. The HIT will be removed from Turk shortly. Thanks for your interest!"
        else
          @disabled = false
        end
      end
    # Else just build a new user for showing the preview
    else
      @user = User.new
      @disabled = true
    end

    # Save in session
    session[:current_user_id] = @user.id if @user.workerId.present?

    get_meal_and_component_counts
  end

  def update
    @user = current_user
    answers = params[:user].present? ? params.require(:user).permit! : nil
    if @user.assign_pre_test(answers.present? ? answers : nil)
      @user.save
      redirect_to new_match_answer_path
    else
      flash.now[:error] = "All questions are required."
      render :new
    end
  end

  def post_test
    @user = current_user
  end

  def update_survey
    @user = current_user
    answers = params[:post_test].present? ? params.require(:post_test).permit! : nil

    if @user.assign_post_test(answers)
      @user.update_attribute(:complete, true)
      redirect_to :completed
    else
      flash.now[:error] = "All questions are required."
      render :post_test
    end
  end

   def completed
    @user = current_user
    reset_session
  end
end