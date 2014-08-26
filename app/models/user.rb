class User < ActiveRecord::Base
  before_create :choose_condition

  MAX_CONDITION = 50
  MIN_CONDITION = 20

  NUM_CONDITIONS = 7

  private

  def choose_condition
    # first need to make sure we have a min number of #1
    if User.where(condition: 1).count < MIN_CONDITION
      self.condition = 1
    elsif User.where(condition: 2).count < MIN_CONDITION
      self.condition = 2
    elsif User.where(condition: 6).count < MIN_CONDITION
      self.condition = 6
    elsif
      self.condition = random_condition
    end
  end

  def random_condition
    1.upto(NUM_CONDITIONS) do |c|
      return c if User.where(condition: c).count < MAX_CONDITION
    end
    return nil
  end

end
