class UsersController < ApplicationController

  def pre_test
    # Only create the user if they have accepted task and there is no user already
    @disabled = true

    # Reload user from session if already assigned
    @user = if current_user
      @disabled = Turkee::TurkeeFormHelper::disable_form_fields?(params)
      current_user
    # Check to see if user exists
    elsif params[:workerId]
      u = User.where(:workerId => params[:workerId]).first
      u.present? ? u : User.create(params.permit(:assignmentId, :workerId, :hitId))
    # Else just create a new user
    else
      @disabled = false
      User.create
    end

        # Make sure we don't have repeat turkers
    if !@user.unique?
      pp "We are totally DIABLING BECAUSE NOT UNIQUE"
      @disabled = true
    end

    session[:current_user_id] = @user.id
  end

  def update
    @user = current_user
    answers = params[:user].present? ? params.require(:user).permit! : nil
    if @user.assign_pre_test(answers.present? ? answers : nil)
      @user.save
      redirect_to new_match_answer_path
    else
      flash.now[:error] = "All questions are required."
      render :pre_test
    end

  end

  def post_test

  end

end