# https://railstutorial.jp/chapters/account_activation?version=5.1#sec-generalizing_the_authenticated_method
#

# 送信メールプレビュー
# /sample_app/config/environments/development.rb
# host = 'rails-tutorial-wmain.c9users.io'
# ブラウザに付け足すURL
# /rails/mailers/user_mailer/account_activation
# /rails/mailers/user_mailer/password_reset


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
  resources :account_activation, only: [:edit]
end

# tips
# cap11 メールでのアカウント有効化
#
# 1, 有効化トークンと有効化digestを関連付ける。
# 2, 有効化トークンをユーザーにメールする。
# 3, ユーザーがそのリンクをクリックすると有効化できるようにする。

# 上記を実装する段取り
# 1, ユーザーの初期状態はunactivatedにする
# 2, ユーザー登録が行われた時、activation_tokenとactivation_digestを生成
# 3, activation_digestはDBに保存し、　activation_tokenはメールで送る。
# 4, ユーザーがメールのリンクをクリックしたら、メールアドレスをキーにしてユーザーを探し、
#    DB内にあるactivation_digestと比較し、認証する。
# 5, ユーザーを認証できたら有効化済み(activated)にする。
