class SessionsController < ApplicationController

  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      if user.activated?
        log_in user
        params[:session][:remember_me] == '1' ? remember(user) : forget(user)
        redirect_back_or user
      else
        message  = "アカウントはまだ有効ではありません。 "
        message += "送られたメールを確認して下さい"
        flash[:warning] = message
        redirect_to root_url
      end
    else
      flash.now[:danger] = 'emailかpasswordが不正です。'
      render 'new'
    end
  end


  # ログイン中の場合のみログアウトする
  def destroy
    log_out if logged_in?
    redirect_to root_url
  end
end
