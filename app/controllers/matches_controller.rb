class MatchesController < ApplicationController

  def new
    @match_answer = MatchAnswer.build_for_random_meal
  end

  def create
    answer_params = params.require(:match_answer).permit!
    @match_answer = MatchAnswer.create(answer_params)
    if @match_answer.valid?
       render :nothing => true
    else
      flash[:error] = "All food items must be matched to at least one group"
      render :new
    end
  end

  def update

  end

end
