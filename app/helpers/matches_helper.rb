module MatchesHelper
  BAR_HEIGHT_MULTIPLER = 2

  def my_answer?(group_arr, item)
    group_arr == @match_answer.food_groups[item]
  end
end