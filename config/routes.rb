# https://railstutorial.jp/chapters/sign_up?version=5.1#sec-signup_form

Rails.application.routes.draw do

  root 'words#index'
  get  '/words/comparison', to: 'words#comparison'
  get  '/answer',           to: 'words#answer'

  resources :users
  resources :words
end

