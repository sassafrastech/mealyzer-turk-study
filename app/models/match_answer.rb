class MatchAnswer < ActiveRecord::Base

  serialize :food_groups, JSON

  validate :food_groups_exist

  # make sure all food groups are accounted for in answer
  def food_groups_exist
    mg = Meal.find(meal_id).food_components
    # Need to parse into object, b/c haven't saved yet
    fg = JSON.parse(food_groups)

    if mg[fg.keys[0]].length != fg.values[0].length
      errors.add(:food_groups, "must be accounted for")
    end
  end

end
