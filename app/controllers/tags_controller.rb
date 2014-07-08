class TagsController < ApplicationController

  def new

  end

  def create
    if Answer.create(answer_params).valid?
      # next, verify if correct in meal model

      # return json hash of acceptable rectangles and a hash of incorrect ones
      render :nothing => true
    else
      #render erros
    end



  end

  def index
    @meal = Meal.first
  end

  private
    def answer_params
      params[:answer].merge!(:user_id => 1)
      Rails.logger.debug(params.inspect)
      params.require(:answer).permit(:meal_id, :food_locations, :user_id)
    end


end
