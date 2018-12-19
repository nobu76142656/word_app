# https://railstutorial.jp/chapters/updating_and_deleting_users?version=5.1#sec-users_index
# ここから未実装
# 11.2 アカウント有効化のメール送信から再開
# https://railstutorial.jp/chapters/account_activation?version=5.1#sec-account_activation_emails

Rails.application.routes.draw do

  root 'words#index'
  get  '/words/comparison', to: 'words#comparison'
  get  '/answer',           to: 'words#answer'
  get  '/timeMeasure',     to: 'words#timeMeasure'

  get    '/login',  to: 'sessions#new'
  post   '/login',  to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  resources :users
  resources :words
end
