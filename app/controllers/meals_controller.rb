class MealsController < ApplicationController
  def index
    @meals = Meal.by_enabled_and_name
  end

  def edit
    @meal = Meal.find(params[:id])
  end

  # Currently only used for updating food locations
  def update
    @meal = Meal.find(params[:id])

    # Assign and save with bang since validation should never fail.
    @meal.assign_attributes(meal_params)
    @meal.save!

    # If we get this far, we just need to return a 200 status code. JS does rest.
    render nothing: true
  end

  private

  def meal_params
    # Get list of permitted hash keys
    location_hash = Hash[*@meal.component_names.map{ |c| [c, [:x, :y, :width, :height]] }.flatten(1)]
    params.require(:meal).permit(food_locations: location_hash)
  end
end
