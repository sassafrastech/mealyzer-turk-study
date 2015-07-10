require "pp"
class UsersController < ApplicationController

  def new
    # Only create the user if they have accepted task and there is no user already
    @disabled = true
    pp "in pretest"

    # Reload user from session if already assigned
    @user = if current_user
      @disabled = Turkee::TurkeeFormHelper::disable_form_fields?(params)
      current_user
    # Check to see if user exists
    elsif params[:workerId]
      @disabled = false
      u = User.where(:workerId => params[:workerId]).first
      u.present? ? u : User.create(params.permit(:assignmentId, :workerId, :hitId, :force_condition))
    # Else just create a new user
    else
      @disabled = Turkee::TurkeeFormHelper::disable_form_fields?(params)
      if (params[:workerId])
        User.create(params.permit(:assignmentId, :workerId, :hitId))
      else
        User.create
      end
    end

        # Make sure we don't have repeat turkers
    if !@user.unique?
      pp "We are totally DIABLING BECAUSE NOT UNIQUE"
      @disabled = true
    end
    if @user.workerId.present?
      session[:current_user_id] = @user.id
    end
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