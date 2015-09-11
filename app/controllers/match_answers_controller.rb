require 'pp'

# This is the main controller used during the study.
class MatchAnswersController < ApplicationController

  before_action :get_meal_and_component_counts

  def new
    #@disabled = false
    #@match_answer = MatchAnswer.next(current_user)
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
    build_summarizer
  end

  def create
    answer_params = params.require(:match_answer).permit!
    answer_params[:user_id] = answer_params[:user_id].to_i
    @match_answer = MatchAnswer.create(answer_params)

    @user = User.find(@match_answer.user_id)
    session[:current_user_id] = @user.id

    if @match_answer.valid?
      @user.increment_tests!
      redirect_by_condition
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
        redirect_to post_test_path
      else
        redirect_to new_match_answer_path
      end
    else
      flash.now[:error] = @match_answer.errors.full_messages.to_sentence
      build_summarizer
      render :edit
    end
  end

  private

  def update_by_condition(params)

    case @match_answer.condition
    when 3,6,10
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
    end
  end

  # Redirects to the appropriate place based on condition and number of trials complete.
  def redirect_by_condition
    # Pre-control, everyone gets constant number
    if @user.num_tests <= Settings.pre_post_control_count
      @match_answer.update_attribute(:task_type, "pre-control")

    # Post-control, everyone gets constant number
    elsif @user.num_tests > User.max_tests - Settings.pre_post_control_count
      @match_answer.update_attribute(:task_type, "post-control")

    # Special case redirects
    else
      case @match_answer.condition
      when 2,3,5,6,9,10
        return redirect_to edit_match_answer_path(@match_answer)
      when 4
        # Find a match answer for same meal/component from seed phase
        equivalent = MatchAnswer.equivalent(@match_answer)
        raise "No equivalent answers found" if equivalent.nil?

        # Make a copy for the user to evaluate and redirect there.
        eval_copy = MatchAnswer.copy_for_eval(equivalent, @match_answer.user)
        return redirect_to edit_match_answer_path(eval_copy)
      when 7,8
        # Every Nth test, reevaluate
        if ((@user.num_tests - Settings.pre_post_control_count) % Settings.reeval_interval) == 0
          return redirect_to edit_match_answer_group_path
        end
      end
    end

    # Default redirect.
    redirect_to @user.max_tests? ? post_test_path : new_match_answer_url
  end

  # Gets the summarizer object used by some conditions.
  def build_summarizer
    @summarizer = MatchAnswerSummarizer.new(@match_answer, current_user)
  end
end
