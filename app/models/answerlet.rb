# Models a set of nutritient selections for one ingredient of one component.
class Answerlet < ActiveRecord::Base
  belongs_to :meal

  serialize :nutrients, JSON

  scope :current_study, -> { where(study_id: Settings.study_id) }

  before_create do
    self.study_id = Settings.study_id
  end

  def self.for_phase(phase)
    User.complete_in_phase(phase).includes(match_answers: :meal).
      map{ |u| u.match_answers.as_answerlets }.flatten
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
    @meal_comp_ing ||= [meal.id, component_name, ingredient]
  end

  def to_s
    "(#{meal.id}, #{component_name}, #{ingredient}, #{ntrnts})"
  end

  def correct_answerlet
    self.class.new(meal: meal, component_name: component_name, ingredient: ingredient,
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
    @attribs ||= [meal, component_name, ingredient, nutrients]
  end
end
