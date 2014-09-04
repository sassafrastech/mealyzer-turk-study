MealyzerStudy::Application.routes.draw do

  root 'home#index'
  resources :meals, :tags
  resources :match_answers do
    member do
      get 'completed'
    end
  end

end
