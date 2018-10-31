Rails.application.routes.draw do
  root 'words#index'
  get '/words/comparison', to: 'words#comparison'
  get '/answer', to: 'words#answer'
  resources :words
end
