# Models a set of nutritient selections for one ingredient of one component.
class Answerlet < ActiveRecord::Base
  belongs_to :match_answer

  serialize :nutrients, JSON

  scope :current_study, -> { includes(:match_answer).where("match_answers.study_id" => Settings.study_id) }

  delegate :meal, :meal_id, :component_name, to: :match_answer

  before_save do
    Meal::GROUPS.each{ |g| self[g.downcase] = nutrients.include?(g) }
  end

  def nutrients=(arr)
    write_attribute(:nutrients, arr.sort)
  end

  def ==(a)
    a.attribs == attribs
  end

  def eql?(a)
    self == a
  end

  def hash
    attribs.hash
  end

  def <=>(a)
    meal_comp_ing <=> a.meal_comp_ing
  end

  def identity
    self
  end

  def meal_comp_ing
    @meal_comp_ing ||= [meal_id, component_name, ingredient]
  end

  def to_s
    "(#{meal.id}, #{component_name}, #{ingredient}, #{ntrnts})"
  end

  def correct_answerlet
    self.class.new(match_answer: match_answer, ingredient: ingredient,
      nutrients: meal.nutrients_for_ingredient(component_name, ingredient))
  end

  def correct?
    @correct ||= (correct_answerlet == self)
  end

  def ntrnts
    @ntrnts ||= nutrients.map{ |n| Meal::GRP_ABBRVS[n] }.join
  end

  protected

  def attribs
    @attribs ||= [meal_id, component_name, ingredient, nutrients]
  end
end
