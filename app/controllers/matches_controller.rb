class MatchesController < ApplicationController

  def new
    @match_answer = MatchAnswer.new
    @meal = Meal.first
  end

  def create

  end

end
