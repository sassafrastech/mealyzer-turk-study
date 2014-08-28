require 'pp'

class MatchesController < ApplicationController

  def new
    # Only create the user if they have accepted task and there is no user already
    @disabled = true
    @user = if session[:current_user_id]
      @disabled = false
      User.find(session[:current_user_id])
    elsif params[:assignmentId]
      @disabled = Turkee::TurkeeFormHelper::disable_form_fields?(params)
      User.create(params.permit(:assignmentId, :workerId, :hitId))
    end
    @match_answer = MatchAnswer.build_for_random_meal(@user)
  end

  def edit
    @match_answer = MatchAnswer.find(params[:id])

    # build evaluation copy
    if @match_answer.condition == 4
      @match_answer = MatchAnswer.copy_for_eval(MatchAnswer.random, @match_answer.user)
    end
    @summarizer = MatchAnswerSummarizer.new(@match_answer.meal_id, @match_answer.component_name)
  end

  def create
    answer_params = params.require(:match_answer).permit!
    @match_answer = MatchAnswer.create(answer_params)

    @user = User.find(@match_answer.user_id)
    session[:current_user_id] = @user.id

    if @match_answer.valid?
      render_by_condition_for_create
    else
      flash[:error] = "All food items must be matched to at least one group"
      redirect_to new_match_answer_path
    end
  end

  def update
    update_params = params.require(:match_answer).permit!
    @match_answer = MatchAnswer.find(params[:id])
    @user = User.find(@match_answer.user_id)

    update_by_condition(update_params)

    if @match_answer.valid?
      if @user.max_tests?
        redirect_to completed_match_answer_path(@match_answer)
      else
        redirect_to new_match_answer_path
      end
    else
      flash[:error] = @match_answer.errors.full_messages.to_sentence
      # save updated answers to show again
      @match_answer.save :validate => false
      redirect_to edit_match_answer_path
    end
  end

  def completed
    @match_answer = MatchAnswer.find(params[:id])
  end

  private

  def update_by_condition(params)
    case @match_answer.condition

    when 3
      @match_answer.food_groups_update = params[:food_groups]
      @match_answer.explanation = params[:explanation]
      @match_answer.build_answers_changed!
      @match_answer.save
    else

    end
  end

  def render_by_condition_for_create
    @user.increment_tests!
    case @match_answer.condition
    when 1
      redirect_to new_match_answer_url
    when 2..3
      redirect_to edit_match_answer_path(@match_answer)
    when 4
      redirect_to edit_match_answer_path(@match_answer)
    when 5
    when 6
    when 7
    else
      Rails.logger.debug("in case else")
    end

  end

end
