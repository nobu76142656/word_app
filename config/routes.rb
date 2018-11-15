Rails.application.routes.draw do
  # get 'users/index'
  # get 'users/show'
  # get 'users/edit'
  
  resources :users
  
  root 'words#index'
  get '/words/comparison', to: 'words#comparison'
  get '/answer', to: 'words#answer'
  
  resources :words
end

