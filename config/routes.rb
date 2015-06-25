MealyzerStudy::Application.routes.draw do

  devise_for :users

  namespace :api do
    scope :v1 do
      mount_devise_token_auth_for 'User', at: 'auth'
      resources :mobile_submissions
      post 'subscribe', to: 'push_notifications#subscribe', as: :subscribe
    end
  end

  resources :mobile_submissions

  # Mechanical Turk routes
  # resources :tags
  # resources :users
  # resources :match_answers
  # resource :match_answer_group
  # get 'finish', to: 'users#post_test', as: :post_test
  # put 'finish', to: 'users#update_survey', as: :finish
  # get 'completed', to: 'users#completed', as: :completed
end
