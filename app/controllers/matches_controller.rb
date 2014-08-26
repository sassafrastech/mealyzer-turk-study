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

  def create
    answer_params = params.require(:match_answer).permit!
    @match_answer = MatchAnswer.create(answer_params)
    session[:current_user_id] = @match_answer.user.id
    if @match_answer.valid?
      render_by_condition
    else
      flash[:error] = "All food items must be matched to at least one group"
      render :new
    end
  end

  def update
    update_params = params.require(:match_answer).permit!
    @match_answer = MatchAnswer.find(update_params[:id])
    @match_answer.food_groups_update = update_params[:food_groups_update]
    @match_answer.build_answers_changed!

    @match_answer.save

    if @match_answer.valid?
      render :update
    else
      @summarizer = MatchAnswerSummarizer.new(@match_answer.meal_id, @match_answer.component_name)
      flash[:error] = "You must make a selection for all food items"
      render :edit
    end
  end


  private

  def render_by_condition
    @match_answer.increment_tests!

    if !@match_answer.max_tests?
      case @match_answer.condition
      when 1
        @match_answer.user
        redirect_to new_match_answer_url
      when 2
        @summarizer = MatchAnswerSummarizer.new(@match_answer.meal_id, @match_answer.component_name)
        render :edit
      when 3
        @summarizer = MatchAnswerSummarizer.new(@match_answer.meal_id, @match_answer.component_name)
        render :edit
      when 4
      when 5
      when 6
      when 7
      else
        Rails.logger.debug("in case else")
      end
    else
      # Render thank you screen and submit to MT
      render :update
    end
  end

end
