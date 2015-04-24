MealyzerStudy::Application.routes.draw do

  devise_for :users, :controllers => { :registrations => "registrations" }

  root 'home#index'
  resources :meals, :tags
  resources :match_answers

  resources :users

  get 'finish', to: 'users#post_test', as: :post_test
  put 'finish', to: 'users#update_survey', as: :finish
  get 'completed', to: 'users#completed', as: :completed
  post 'subscribe', to: 'push_notifications#subscribe', as: :subscribe


  resource :match_answer_group

  resources :mobile_submissions

end
