class MatchesController < ApplicationController

  def new
    @answer = Answer.new
    @meal = Meal.first
  end

  def create

  end

end
