require 'rails_helper'

describe MatchAnswer do
  context "after match answer has been submitted" do
    before do
      @meal = Meal.create(:name => "Chicken Dinner", :food_components => {'honey chicken' => ['chicken', 'butter', 'honey'], 'asparagus' => ['asparagus', 'butter', 'salt']})
      @match_answer = MatchAnswer.new(:meal_id => @meal.id, :user_id => 2,
        :food_groups => {"honey chicken" => {"chicken" => ["protein", "fat"], "honey" => ["fat"], "butter" => ["fat"]}})
      @match_answer2 = MatchAnswer.new(:meal_id => @meal.id, :user_id => 3,
        :food_groups => {"honey chicken" => {"chicken" => ["protein"], "honey" => ["fat"], "butter" => ["fat"]}})
      @match_answer3 = MatchAnswer.new(:meal_id => @meal.id, :user_id => 5,
        :food_groups => {"honey chicken" => {"chicken" => ["fat"], "honey" => ["fat"], "butter" => ["fat"]}})
      @match_answer4 = MatchAnswer.new(:meal_id => @meal.id, :user_id => 5,
        :food_groups => {"honey chicken" => {"chicken" => ["protein", "fat"], "honey" => ["fat"], "butter" => ["fat"]}})
      @match_answer4 = MatchAnswer.new(:meal_id => @meal.id, :user_id => 5,
        :food_groups => {"asparagus" => {"chicken" => ["protein", "fat"], "honey" => ["fat"], "butter" => ["fat"]}})

      @match_answer.save(:validate => false)
      @match_answer2.save(:validate => false)
      @match_answer3.save(:validate => false)
      @match_answer4.save(:validate => false)
    end

    it "should return correct community answers" do
      MatchAnswerSummarizer.new("1", "honey chicken")

    end

  end

end
