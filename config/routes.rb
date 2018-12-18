# https://railstutorial.jp/chapters/advanced_login?version=5.1#sec-remember_me_checkbox
#

Rails.application.routes.draw do

  root 'words#index'
  get  '/words/comparison', to: 'words#comparison'
  get  '/answer',           to: 'words#answer'

  get    '/login',  to: 'sessions#new'
  post   '/login',  to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  resources :users
  resources :words
end
