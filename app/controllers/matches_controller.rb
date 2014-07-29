class MatchesController < ApplicationController

  def new
    @match_answer = MatchAnswer.new
    @meal = Meal.random
    @match_answer.sample_component = @meal.sample_component
  end

  def create
    @match_answer = MatchAnswer.new(answer_params)
    if @match_answer.valid?
       @match_answer.save
       render :nothing => true
    else
      flash[:error] = "All food items must be matched to at least one group"
      sc = JSON.parse(@match_answer.sample_component)
      @match_answer.sample_component = MealComponent.new(sc['name'], sc['items'])
      @meal = Meal.find(@match_answer.meal_id)
      render :new
    end
  end

  def update

  end


  private
    def answer_params
      params[:match_answer][:food_groups] = params[:match_answer][:food_groups].to_json
      params.require(:match_answer).permit(:meal_id, :user_id, :food_groups, :sample_component)
    end

end
