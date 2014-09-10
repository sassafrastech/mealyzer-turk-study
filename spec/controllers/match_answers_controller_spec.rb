require 'rails_helper'
require 'pp'

RSpec.describe MatchAnswersController do

  describe "GET new" do
    before do
      @meal = Meal.create(:name => "Chicken Dinner", :food_components => {'honey chicken' => ['chicken', 'butter', 'honey'], 'asparagus' => ['asparagus', 'butter', 'salt']},
        :food_nutrition => {'honey chicken' => {'chicken' => ['protein', 'fat']}})
    end

    it "assigns condition 1 the first time" do
      get :new
      expect(assigns(:user).condition == 1)
    end

  end


end