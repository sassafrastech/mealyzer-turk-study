MealyzerStudy::Application.routes.draw do

  root 'home#index'
  resources :meals, :tags
  resources :match_answers

  resources :users
  get 'start', to: 'users#pre_test', as: :pre_test
  get 'finish', to: 'users#post_test', as: :post_test

  resource :match_answer_group

end
