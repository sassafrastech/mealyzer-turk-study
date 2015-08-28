# WARNING: This task will mark all existing meals as disabled
# Usage: e.g. rake db:load_meals[lib/meal_data/mydata.yml]
PHOTO_DIR = File.join(Rails.root, "app/assets/images/meals")

def abort2(msg)
  puts msg
  raise ActiveRecord::Rollback
end

namespace :db do
  desc "Load meal data from YML file."
  task :load_meals, [:filename] => :environment do |t, args|
    abort("Usage: rake db:load_meals[<file path>]") unless args[:filename].present?

    meals = YAML.load_file(args[:filename]).with_indifferent_access rescue abort($!.to_s)

    Meal.transaction do
      # Disable all previous meals
      Meal.update_all(disabled: true)

      meals.each do |num, data|
        attribs = {food_components: {}, food_nutrition: {}}

        # Open photo file
        file = data[:file]
        abort2("ERROR: No filename found for meal #{num}") if file.blank?
        path = File.join(PHOTO_DIR, data[:file])
        attribs[:photo] = File.open(path) rescue abort2("ERROR: File #{path} not found")

        # Validate
        abort2("ERROR: No name found for meal #{num}") if data[:name].blank?
        abort2("ERROR: No components found for meal #{num}") if data[:components].blank?
        abort2("ERROR: Invalid set_num for meal #{num}") if data[:set_num] && !data[:set_num].is_a?(Fixnum)

        attribs[:name] = data[:name]
        attribs[:photo_credit] = data[:credit]
        attribs[:set_num] = data[:set_num]

        # Build food_components and food_nutrition
        data[:components].each do |cname, ingredients|
          if !ingredients.is_a?(Hash) || ingredients.empty?
            abort2("ERROR: No ingredients found for meal #{num} component #{cname}")
          end

          attribs[:food_components][cname] = ingredients.keys

          ingredients.each do |iname, groups|
            groups = groups.split(/\s*,\s*/)
            if (invalid = groups - Meal::GROUPS).any?
              abort2("ERROR: Invalid group(s) #{invalid.join(',')} in meal #{num}")
            end
            ingredients[iname] = groups
          end
          attribs[:food_nutrition][cname] = ingredients
        end

        puts "Adding ##{num}: #{attribs[:name]}"
        Meal.create!(attribs)
      end

      # Verify set nums
      nums = Meal.enabled.pluck(:set_num).compact.uniq.sort
      if nums.any?
        abort2("ERROR: Invalid set_num sequence #{nums.join(',')}") unless nums == (1..nums.last).to_a

        nums.each do |n|
          if (c = Meal.enabled.where(set_num: n).count) != 3
            abort2("ERROR: Set #{n} has #{c} items instead of 3")
          end
        end
      end
    end
  end
end
