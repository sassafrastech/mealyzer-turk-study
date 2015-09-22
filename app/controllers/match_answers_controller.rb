require 'pp'

# This is the main controller used during the study.
class MatchAnswersController < ApplicationController

  before_action :get_meal_and_component_counts

  def new
    return render text: "No current user", status: 403 unless current_user

    @disabled = false
    @user = current_user
    @match_answer = MatchAnswer.next(@user)

    # If this is the explain phase, we save @match_answer immediately because
    # it is a fake answer that the user will be asked to evaluate.
    if @user.study_phase == "explain"
      @match_answer.save!
      redirect_by_condition
    end
  end

  def edit
    @match_answer = MatchAnswer.find(params[:id])
    build_summarizers
  end

  def create
    answer_params = params.require(:match_answer).permit!
    answer_params[:user_id] = answer_params[:user_id].to_i
    answer_params[:study_id] = Settings.study_id
    @match_answer = MatchAnswer.create(answer_params)

    @user = User.find(@match_answer.user_id)
    session[:current_user_id] = @user.id

    if @match_answer.valid?
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
      build_summarizers
      render :edit
    end
  end

  private

  def update_by_condition(params)
    case @match_answer.condition
    when 3,4,6,10,11,12,13,14
      @match_answer.food_groups_update = params[:food_groups]
      @match_answer.explanation = params[:explanation]
      @match_answer.build_answers_changed!
      @match_answer.impact = params[:impact] if @match_answer.condition == 4
      @match_answer.save
    end
  end

  # Redirects to the appropriate place based on condition and number of trials complete.
  def redirect_by_condition
    @user.increment_tests!

    # Pre-control, everyone gets constant number
    if @user.study_phase == "main" && @user.num_tests <= Settings.pre_post_control_count
      @match_answer.update_attribute(:task_type, "pre-control")

    # Post-control, everyone gets constant number
    elsif @user.study_phase == "main" && @user.num_tests > User.max_tests - Settings.pre_post_control_count
      @match_answer.update_attribute(:task_type, "post-control")

    # Special case redirects
    else
      case @user.condition
      when 2,3,5,6,9,10,11,13,14
        return redirect_to edit_match_answer_path(@match_answer)
      when 4
        # Find a match answer for same meal/component from seed phase
        equivalent = MatchAnswer.equivalent(@match_answer)
        raise "No equivalent answers found" if equivalent.nil?

        # Make a copy for the user to evaluate and redirect there.
        eval_copy = equivalent.copy_for_eval(@match_answer.user)
        return redirect_to edit_match_answer_path(eval_copy)
      when 7,8
        # Every Nth test, reevaluate
        if ((@user.num_tests - Settings.pre_post_control_count) % Settings.reeval_interval) == 0
          return redirect_to edit_match_answer_group_path
        end
      when 12
        eval_copy = @match_answer.copy_for_eval(current_user)
        return redirect_to edit_match_answer_path(eval_copy)
      end
    end

    # Default redirect.
    redirect_to @user.max_tests? ? post_test_path : new_match_answer_url
  end

  # Gets the summarizer object used by some conditions.
  def build_summarizers
    @summarizer = MatchAnswerSummarizer.new(@match_answer, current_user)

    if [13, 14].include?(current_user.condition)
      summ = AnswerletSummarizer.new
      @most_popular = Hash[*@match_answer.food_groups.keys.map do |ingredient|
        [ingredient, summ.most_popular_per_nutrient(
          meal_id: @match_answer.meal_id, component_name: @match_answer.component_name, ingredient: ingredient)]
      end.flatten]
    end
  end
end
