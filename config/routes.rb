# https://railstutorial.jp/chapters/password_reset?version=5.1#cha-password_reset
# 12章から

# https://railstutorial.jp/chapters/account_activation?version=5.1#sec-generalizing_the_authenticated_method
# 11.3.1 authenticated?メソッドの抽象化 を復習

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

  # resourcesは全て複数形となる！！
  resources :users
  resources :words
  resources :account_activations, only: [:edit]
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


# tips
# メールの送信内容について：
#
# railsサーバーでユーザーをメールアドレスで検索して有効化トークンを認証できるようにする
# のでリンクにはメールアドレスとactivation_tokenを含める。
# edit_account_activation_url(@user.activation_token)
# は
# edit_user_url(user)
# が
# http://www.example.com/users/1/edit
# を表すことにあてはまると
# http://www.example.com/account_activations/q5lt38hQDc_959PVoo6b7A/edit
# となる。さらに、urlの最後に?を追加し、それ以降にキーと値のペアを付けた形は以下となる。
# account_activations/q5lt38hQDc_959PVoo6b7A/edit?email=foo%40example.com

# これをリンクで表記するとすると、
# edit_account_activation_url(@user.activation_token, email: @user.email)
# となる。


# cap12 パスワード再設定
#
# PasswordResetsリソースを作成し、再設定用トークンとそれに対応するdigestを保存するのが今回
# の目的となる。

# 1、ユーザーがパスワード再設定をリクエストすると、ユーザーが送信したメールアドレスをキーにして
# データベースからユーザーを見つける。
# 2、該当のメールアドレスがDBにある場合は再設定用tokenと対応するdigestを生成。
# 3、再設定用digestはDBに保存しておき、再設定用tokenはメールアドレスと一緒に、ユーザーに送信
# する有効化用のメールのリンクに組み入れる。
# 4、ユーザーがメールのリンクをクリックしたら、メールアドレスをキーとしてユーザーを探し、DB内に
# 保存してある再設定用digestと比較し、トークンを認証する。
# 5、認証に成功したら、パスワード変更用のフォームをユーザーに表示する。


