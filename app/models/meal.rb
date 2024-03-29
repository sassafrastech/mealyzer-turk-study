class Meal < ActiveRecord::Base
  %w(food_locations food_options food_nutrition food_components).each {|column| serialize column, JSON}

  GROUPS = ["Protein", "Fat", "Carbohydrate", "Fiber"]
  LC_GROUPS = GROUPS.map(&:downcase)
  VOWELS = %w(a e i o u)
  GRP_ABBRVS = ActiveSupport::OrderedHash[*GROUPS.sort.map{ |g| [g, (g.split(//) - VOWELS)[0,2].join] }.flatten]

  has_attached_file :photo, :styles => { :thumb => "100x100#" }, :default_url => "/images/:style/missing.png"
  validates_attachment_content_type :photo, :content_type => /\Aimage\/.*\Z/

  scope :enabled, -> { where(disabled: false) }
  scope :by_enabled_and_name, -> { order(:disabled, :name) }

  def self.random
    Meal.enabled.first(:offset => rand(Meal.enabled.count))
  end

  # Returns an array of pairs of form [meal_id, component name] for all Meals in system.
  def self.all_tests
    @all_tests ||= build_all_tests
  end

  def sample_component_name
    food_components.keys.sample
  end

  def items_for_component(name)
    food_components[name]
  end

  def nutrients_for_ingredient(component_name, ingredient)
    food_nutrition.try(:[], component_name).try(:[], ingredient) || []
  end

  def location_for_component(name)
    food_locations.try(:[], name)
  end

  def component_names
    food_components.try(:keys) || []
  end

  private

  def self.build_all_tests
    all_tests = []
    Meal.enabled.all.each do |meal|
      meal.food_components.each do |k,v|
        all_tests << [meal.id, k]
      end
    end
    return all_tests
  end
end
