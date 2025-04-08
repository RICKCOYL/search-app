Rails.application.routes.draw do
  root 'search/search#index'
  get 'search', to: 'search/search#search'
end