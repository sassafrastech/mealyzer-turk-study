require 'rails_helper'
require 'pp'

describe MatchAnswer do

  context "For condition 4" do
    before do
      @meal = Meal.create(:name => "Chicken Dinner", :food_components => {'honey chicken' => ['chicken', 'butter', 'honey'], 'asparagus' => ['asparagus', 'butter', 'salt']},
        :food_nutrition => {'honey chicken' => {'chicken' => ['protein', 'fat']}})
      @match_answer = MatchAnswer.new(:meal_id => @meal.id, :user_id => 2,
        :food_groups => nil)
      @match_answer2 = MatchAnswer.new(:meal_id => @meal.id, :user_id => 3,
        :food_groups => {"honey chicken" => {"chicken" => ["protein"], "honey" => ["fat"], "butter" => ["fat"]}})
      @match_answer3 = MatchAnswer.new(:meal_id => @meal.id, :user_id => 5,
        :food_groups => {"asparagus" => {"chicken" => ["protein", "fat"], "honey" => ["fat"], "butter" => ["fat"]}})

      @match_answer.save(:validate => false)
      @match_answer2.save(:validate => false)
      @match_answer3.save(:validate => false)
    end

    it "should return a non-null match answer" do
      expect(MatchAnswer.random.food_groups).to_not be(nil)
    end

  end

end
