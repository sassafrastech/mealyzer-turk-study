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

  task :score_surveys => :environment do
    answers = MatchAnswer.joins(:user)
    answers.each do |a|

      next if a.user.pre_test.nil? || a.user.post_test.nil?
      puts "USER #{a.user.inspect}"
      a.user.pre_test_score = 0
      a.user.post_test_score = 0
      a.user.pre_test.each do |r|
        a.user.pre_test_score += r.last.to_i
      end
      a.user.post_test.each do |r|
        a.user.post_test_score += r.last.to_i
      end
      puts "pre test: #{a.user.pre_test_score}\n"
      puts "post test: #{a.user.post_test_score}"
      pp "NOW USER IS: #{a.user.inspect}"
      a.user.save :validate => false
    end
  end

  task :evaluate_answers => :environment do
    match_answers = MatchAnswer.where('food_groups IS NOT NULL')
    pp "STARTING ************  there are #{match_answers.length} records"
    match_answers.each do |a|
      pp "------- looking at ma id: #{a.id}"
      a.num_ingredients = a.food_groups.keys.length
      pp "NUM ING: #{a.num_ingredients}"

      a.food_groups_correct = a.meal.food_nutrition[a.component_name] == a.food_groups
      pp "Evaluating food group: #{a.food_groups}"
      pp "Correct answer: #{Meal.find(a.meal_id).food_nutrition[a.component_name]}"
      pp "Food group correct? #{a.food_groups_correct}"

      answers = a.individual_answers(a.food_groups)

      # individual assessment
      a.food_groups_correct_all = answers
      pp "EVALUTED: #{a.food_groups_correct_all}"

      values = []
      answers.values.each do |v|
        v.each_value {|value| values.push(value)}
      end

      a.num_correct = values.select{|a| a == "correct"}.length
      pp "NUM CORRECT #{a.num_correct}"



      if !a.food_groups_update.blank?
        a.food_groups_update_correct = a.meal.food_nutrition[a.component_name] == a.food_groups_update

        answers = a.individual_answers(a.food_groups_update)

        # individual assessment
        a.food_groups_update_correct_all = answers

        values = []
        answers.values.each do |v|
          v.each_value {|value| values.push(value)}
        end

        a.num_correct_update = values.select{|a| a == "correct"}.length

        pp "NUM CORRECT #{a.num_correct_update}"
      else
        pp "** food groups update is blank or already graded"
        pp "---------- end -----------"

      end

      a.save :validate => false



    end

  end


  task :evaluate_all_answers => :environment do
    # get all match answers that haven't been evaluated yet
    match_answers = MatchAnswer.where('food_groups IS NOT NULL AND food_groups_correct_all IS NULL')

    match_answers.each do |a|
      pp "evaluating answer: #{a}"
      a.save :validate => false
    end

  end
end
