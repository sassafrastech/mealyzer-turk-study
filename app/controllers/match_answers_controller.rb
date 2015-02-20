require 'pp'

class MatchAnswersController < ApplicationController

  def new
    # Only create the user if they have accepted task and there is no user already
    @disabled = true

    # Reload user from session if already assigned
    @user = if !current_user.nil?
      @disabled = false
      current_user
    elsif params[:assignmentId]
      @disabled = Turkee::TurkeeFormHelper::disable_form_fields?(params)
      User.create(params.permit(:assignmentId, :workerId, :hitId))
    else
      @user = User.create
    end

    # Make sure we don't have repeat turkers
    if !@user.unique? && User::REQUIRE_UNIQUE
      @disabled = true
    end

    @match_answer = MatchAnswer.next(@user)
  end

  def edit
    @match_answer = MatchAnswer.find(params[:id])
    # Build evaluation copy
    if @match_answer.condition == 4
      @match_answer = MatchAnswer.copy_for_eval(MatchAnswer.random, @match_answer.user)
    end
    @summarizer = MatchAnswerSummarizer.new(@match_answer.meal_id, @match_answer.component_name)
  end

  def create
    answer_params = params.require(:match_answer).permit!
    answer_params[:user_id] = answer_params[:user_id].to_i
    @match_answer = MatchAnswer.create(answer_params)

    @user = User.find(@match_answer.user_id)
    session[:current_user_id] = @user.id

    if @match_answer.valid?
      render_by_condition_for_create
    else
      flash.now[:error] = "All food items must be matched to at least one group"
      render :new
    end
  end

  def update
    update_params = params.require(:match_answer).permit!
    @match_answer = MatchAnswer.find(params[:id])
    @user = User.find(@match_answer.user_id)

    update_by_condition(update_params)

    if @match_answer.valid?
      # Check if we have done enough tests yet
      if @user.max_tests?
        redirect_to completed_match_answer_path(@match_answer)
      else
        redirect_to new_match_answer_path
      end
    else
      flash.now[:error] = @match_answer.errors.full_messages.to_sentence
      @summarizer = MatchAnswerSummarizer.new(@match_answer.meal_id, @match_answer.component_name)
      render :edit
    end
  end

  def completed
    @match_answer = MatchAnswer.find(params[:id])
    reset_session
  end

  private

  def update_by_condition(params)

    case @match_answer.condition
    when 3,6
      @match_answer.food_groups_update = params[:food_groups]
      @match_answer.explanation = params[:explanation]
      @match_answer.build_answers_changed!
      @match_answer.save
    when 4
      @match_answer.food_groups_update = params[:food_groups]
      @match_answer.explanation = params[:explanation]
      @match_answer.build_answers_changed!
      @match_answer.impact = params[:impact]
      @match_answer.save
    when 5
      # do nothing

    when 7

    end
  end

  def render_by_condition_for_create
    @user.increment_tests!
    if @user.max_tests? && (@user.condition == 1 || @user.condition == 7)
      redirect_to completed_match_answer_path(@match_answer)
    else

      Rails.logger.debug("condition: #{@match_answer.condition}")
      Rails.logger.debug("num tests: #{@match_answer.num_tests}")
      case @match_answer.condition
      when 1
        redirect_to new_match_answer_url
      when 2..6
        redirect_to edit_match_answer_path(@match_answer)
      when 6
      when 7
        # if this is the 5th test
        if (@user.num_tests % 5) == 0
          redirect_to edit_match_answer_group_path
        else
          redirect_to new_match_answer_url
        end
      else
        Rails.logger.debug("in case else")
      end

    end

  end

end
