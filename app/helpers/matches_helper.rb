module MatchesHelper
  BAR_MAX_HEIGHT = 20

  def my_answer?(group_arr, item)
    group_arr == @match_answer.food_groups[item]
  end
end