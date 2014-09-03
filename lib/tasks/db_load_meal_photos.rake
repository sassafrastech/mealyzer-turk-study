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
end