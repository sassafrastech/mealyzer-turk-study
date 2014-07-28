class MatchesController < ApplicationController

  def new
    @match_answer = MatchAnswer.new
    @meal = Meal.random
  end

  def create
    @match_answer = MatchAnswer.create(answer_params)
    if @match_answer.valid?
       render :nothing => true
    else
      flash[:error] = "All food items must be matched to at least one group"
      @meal = Meal.find(@match_answer.meal_id)
      render :new
    end
  end

  def update

  end


  private
    def answer_params
      params[:match_answer][:food_groups] = params[:match_answer][:food_groups].to_json
      params.require(:match_answer).permit(:meal_id, :user_id, :food_groups)
    end

end
