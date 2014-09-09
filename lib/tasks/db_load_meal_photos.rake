require "pp"
namespace :db do
  task :load_meal_photos => :environment do
    MEALS_PHOTO_PATH = "#{Rails.root}/app/assets/images/meals/"
    Dir.foreach(MEALS_PHOTO_PATH) do |photo|
      next if photo == '.' or photo == '..' or photo == '.DS_Store'
      puts "photo that we are processing: #{photo}"

      photo_path, meal, meal_id = nil
      photo_path = File.basename(photo, '*.')
      meal_id = File.basename(photo, '.*')
      puts "looking for meal_id #{meal_id}"
      meal = Meal.find(meal_id)
      puts "found meal: #{meal.inspect}"
      raise "could not find meal with id #{meal_id}" if meal.nil?

      File.open(MEALS_PHOTO_PATH + photo) do |f|
        puts "opening file: #{MEALS_PHOTO_PATH + photo}"
        meal.photo = f
        meal.save
        puts "saved photo to meal"
        puts meal.errors.messages
      end
    end
  end

  task :evaluate_answers => :environment do
    match_answers = MatchAnswer.where('food_groups IS NOT NULL')
    pp "STARTING ************  there are #{match_answers.length} records"
    match_answers.each do |a|
      pp "------- looking at ma id: #{a.id}"
      if a.food_groups_correct.nil? && !a.food_groups.blank?
        pp "IS IT BLANK? #{a.food_groups_correct}"
        a.food_groups_correct = Meal.find(a.meal_id).food_nutrition[a.component_name].eql?(a.food_groups)
        pp "Evaluating food group: #{a.food_groups}"
        pp "Correct answer: #{Meal.find(a.meal_id).food_nutrition[a.component_name]}"
        pp "Food group correct? #{a.food_groups_correct}"
        a.save :validate => false
        pp "--------- saved ----------"
      else
        pp "** food groups is blank or already graded"
        pp "---------- end -----------"
      end

      if a.food_groups_update_correct.nil? && !a.food_groups_update.blank?
        a.food_groups_update_correct = Meal.find(a.meal_id).food_nutrition[a.component_name].eql?(a.food_groups_update)
        pp "Evaluating food group update: #{a.food_groups_update}"
        pp "Correct answer: #{Meal.find(a.meal_id).food_nutrition[a.component_name]}"
        pp "Food group correct? #{a.food_groups_update_correct}"
        a.save :validate => false
        pp "--------- saved ----------"
      else
        pp "** food groups update is blank or already graded"
        pp "---------- end -----------"

      end


    end

  end
end