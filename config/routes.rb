MealyzerStudy::Application.routes.draw do

  root 'home#index'
  resources :meals, :tags
  resources :match_answers

  resources :users

  get 'tryout', to: 'tryouts#index'

  get 'finish', to: 'users#post_test', as: :post_test
  put 'finish', to: 'users#update_survey', as: :finish
  get 'completed', to: 'users#completed', as: :completed


  resource :match_answer_group

  match 'process', to: 'process#create', via: :post

end
