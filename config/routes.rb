Rails.application.routes.draw do
  root 'articles#index'
  
  resources :articles, only: [:index]
  resources :searches, only: [:index, :create]
  resources :analytics, only: [:index]
  
  namespace :api do
    namespace :v1 do
      post '/record_search', to: 'searches#record'
      get '/search', to: 'searches#search'
      get '/analytics', to: 'analytics#index'
    end
  end
end