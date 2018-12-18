class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      # ユーザーログイン後にユーザー情報のページにリダイレクトする
      log_in user
      params[:session][:remember_me] == '1' ? remember(user) : forget(user)
      remember user
      redirect_to user
    else
      # エラーメッセージを作成
      flash.now[:danger] = 'メールアドレスまたはパスワードが間違っています'
      render 'new'
    end
  end

  # ログイン中の場合のみログアウトする
  def destroy
    log_out if logged_in?
    redirect_to root_url
  end
end
