MealyzerStudy::Application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  root 'home#index'
  resources :meals
  resources :tags, :only => :index

end
