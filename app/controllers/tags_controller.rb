class TagsController < ApplicationController

  def new

  end

  def index
    @meal = Meal.first
  end

end