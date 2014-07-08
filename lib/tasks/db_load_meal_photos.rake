namespace :db do
  task :load_meal_photos => :environment do
    MEALS_PHOTO_PATH = "#{Rails.root}/app/assets/images/meals/"
    Dir.foreach(MEALS_PHOTO_PATH) do |photo|
      next if photo == '.' or photo == '..'
      photo_path, meal, meal_id = nil
      photo_path = File.basename(photo)[0]
      meal_id = File.basename(photo_path, '.*')
      meal = Meal.find(meal_id)
      raise "could not find meal with id #{meal_id}" if meal.nil?

      File.open(MEALS_PHOTO_PATH + photo) do |f|
        meal.photo = f
        meal.save
        puts meal.errors.messages
      end
    end
  end
end