require 'pp'
class MatchesController < ApplicationController

  def new
    @match_answer = MatchAnswer.build_for_random_meal
  end

  def create
    answer_params = params.require(:match_answer).permit!
    @match_answer = MatchAnswer.create(answer_params)
    if @match_answer.valid?
      @summarizer = MatchAnswerSummarizer.new(@match_answer.meal_id, @match_answer.component_name)
      render :edit
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

end
