# https://railstutorial.jp/chapters/updating_and_deleting_users?version=5.1#sec-partial_refactoring
#

# 送信メールプレビュー
# /sample_app/config/environments/development.rb
# host = 'rails-tutorial-wmain.c9users.io'
# ブラウザに付け足すURL
# /rails/mailers/user_mailer/account_activation
# /rails/mailers/user_mailer/password_reset
# 送信メールプレビュー部分だけは実装。その他実装していない。

# boolen型のカラム、adminなどを作るとrailsでは自動的に論理値を返すadmin?メソッドが使える。

Rails.application.routes.draw do

  root 'words#index'
  get  '/words/comparison', to: 'words#comparison'
  get  '/answer',           to: 'words#answer'
  get  '/result',           to: 'words#result'



  get    '/login',  to: 'sessions#new'
  post   '/login',  to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  resources :users
  resources :words
end
