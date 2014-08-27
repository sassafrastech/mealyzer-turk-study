MealyzerStudy::Application.routes.draw do

  root 'home#index'
  resources :meals, :tags, :matches
  resources :match_answers, controller: 'matches' do
    member do
      get 'completed'
    end
  end

end
