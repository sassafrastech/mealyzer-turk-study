# Models a set of nutritient selections for one ingredient of one component.
# Not persisted
class Answerlet
  attr_accessor :meal, :component_name, :ingredient, :nutrients

  VOWELS = %w(a e i o u)

  def initialize(attribs)
    attribs.each{|k,v| instance_variable_set("@#{k}", v)}
    self.nutrients = nutrients.sort
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
    sort_key <=> a.sort_key
  end

  def identity
    self
  end

  def to_s
    "(#{meal.id}, #{component_name}, #{ingredient}, #{ntrnts})"
  end

  def correct?
    @correct ||= (meal.nutrients_for_ingredient(component_name, ingredient).sort == nutrients)
  end

  def ntrnts
    @ntrnts ||= nutrients.map{ |n| (n.split(//) - VOWELS)[0,2].join }.join
  end

  protected

  def sort_key
    @sort_key ||= [meal.id, component_name, ingredient]
  end

  def attribs
    @attribs ||= [meal, component_name, ingredient, nutrients]
  end
end
