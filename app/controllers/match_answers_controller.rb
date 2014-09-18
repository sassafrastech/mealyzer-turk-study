require 'pp'

class MatchAnswersController < ApplicationController

  def new
    @disabled = false
    @match_answer = MatchAnswer.next(current_user)
  end

  def edit
    @match_answer = MatchAnswer.find(params[:id])
    # Build evaluation copy
    if @match_answer.condition == 4
      @match_answer = MatchAnswer.copy_for_eval(MatchAnswer.equivalent(@match_answer), @match_answer.user)
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
        redirect_to post_test_path(@match_answer)
      else
        redirect_to new_match_answer_path
      end
    else
      flash.now[:error] = @match_answer.errors.full_messages.to_sentence
      @summarizer = MatchAnswerSummarizer.new(@match_answer.meal_id, @match_answer.component_name)
      render :edit
    end
  end

  private

  def update_by_condition(params)

    case @match_answer.condition
    when 3,6
      @match_answer.food_groups_update = params[:food_groups]
      @match_answer.explanation = params[:explanation].html_safe
      @match_answer.build_answers_changed!
      @match_answer.save
    when 4
      @match_answer.food_groups_update = params[:food_groups]
      @match_answer.explanation = params[:explanation].html_safe
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

    # Pre-test, everyone gets 5
    if @user.num_tests <= 5
      @match_answer.task_type = "pre-test"
      @match_answer.save :validate => false
      redirect_to new_match_answer_url
    else

      if @user.max_tests? && (@user.condition == 1 || @user.condition == 7 || @user.condition == 8)
        redirect_to post_test_path(@match_answer)
      else

        Rails.logger.debug("condition: #{@match_answer.condition}")
        Rails.logger.debug("num tests: #{@match_answer.num_tests}")
        case @match_answer.condition
        when 1
          redirect_to new_match_answer_url
        when 2..6
          redirect_to edit_match_answer_path(@match_answer)
        when 6
        when 7,8
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

end
