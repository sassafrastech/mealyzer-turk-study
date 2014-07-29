class MatchAnswer < ActiveRecord::Base

  serialize :food_groups, JSON
  serialize :sample_component, JSON

  validate :food_groups_exist

  # make sure all food groups are accounted for in answer
  def food_groups_exist
    # Need to parse into object, b/c haven't saved yet
    fg = JSON.parse(food_groups)
    sc = JSON.parse(sample_component)
    if sc['items'].length != fg.values[0].keys.length
      errors.add(:food_groups, "must be accounted for")
    end
  end

  def cb_checked?(food_item, nutrition)
    if food_groups.nil?
      return false
    end

    fg = JSON.parse(food_groups)
    if fg[sample_component.name].nil? || fg[sample_component.name][food_item].nil?
      return false
    else
      fg = JSON.parse(food_groups)
      fg[sample_component.name][food_item].include?(nutrition)
    end

  end

end
