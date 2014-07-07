class TagsController < ApplicationController

  def new

  end

  def create
    # create new meal coordinates
    Rails.logger.debug(params.inspect)
    Answer.create(params)
    # verify if correct
    @meal.correct(params)
    # return json hash of correct rectangles and a hash of incorrect ones
  end

  def index
    @meal = Meal.first
  end

end
