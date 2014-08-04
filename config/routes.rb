MealyzerStudy::Application.routes.draw do

  root 'home#index'
  resources :meals, :tags, :matches
  resources :match_answers, controller: 'matches'
end
