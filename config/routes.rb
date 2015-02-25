MealyzerStudy::Application.routes.draw do

  root 'home#index'
  resources :meals, :tags
  resources :match_answers do
    member do
      get 'completed'
    end
  end

  resource :match_answer_group

  resources :mobile_submissions

end
