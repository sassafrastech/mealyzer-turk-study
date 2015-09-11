MealyzerStudy::Application.routes.draw do

  root 'home#index'
  resources :meals
  resources :match_answers
  resources :users

  get 'admin', to: 'admin#index'
  delete 'admin', to: 'admin#exit'

  get 'finish', to: 'users#post_test', as: :post_test
  put 'finish', to: 'users#update_survey', as: :finish
  get 'completed', to: 'users#completed', as: :completed

  resource :match_answer_group

  match 'process', to: 'process#create', via: :post

end
