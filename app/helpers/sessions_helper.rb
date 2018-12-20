module SessionsHelper

  # 渡されたユーザーでログインする
  def log_in(user)
    session[:user_id] = user.id
  end

  # ユーザーのセッションを永続的にする。Userクラスにもrememberメソッドがある。混同注意。
  # signedで永続かされ暗号化されたユーザーIDと永続化（20年）されたtokenをブラウザのcookiesに保存。
  def remember(user)
    user.remember
    cookies.permanent.signed[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end

  # 現在ログイン中のユーザーを返す（いる場合）
  # 一時セッションにしか対応していない
  # def current_user
  #   if session[:user_id]
  #     @current_user ||= User.find_by(id: session[:user_id])
  #   end
  # end

  # 渡されたユーザーがログイン済みユーザーであればtrueを返す
  def current_user?(user)
    user == current_user
  end

  # 上記を永続セッションに対応させる
  # 現在ログイン中のユーザーを@current_userに入れる
  def current_user
    # log_inメソッドでsession[:user_id]にuser.idを代入してログイン状態にしていれば
    if session[:user_id]
      # session[:user_id]にlog_inメソッドでuser.idを代入している。
      # @current_userがいたらそのまま、いなかったらuser.idからユーザーを検索し
      # ユーザーを入れる。
      @current_user ||= User.find_by(id: session[:user_id])

    # cookies[:user_id]にuser.idが入っていれば
    elsif cookies.signed[:user_id]
      # user.idをキーとしてユーザーを検索
      user = User.find_by(id: cokies.signed[:user_id])
      # 検索の結果userがいて、かつ、authenticated?でtrueが返ったら
      if user && user.authenticated?(cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end

  # ユーザーがログインしていればtrue、その他ならfalseを返す
  def logged_in?
    !current_user.nil?
  end

  # 永続的セッションを破棄する(Userクラスでforgetが定義されている)
  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  # 現在のユーザーをログアウトする
  def log_out
    forget(current_user)
    session.delete(:user_id)
    @current_user = nil
  end

  # フレンドリーフォワーディングの実装：
  # ログインしていないユーザーが編集ページにアクセスすると、自分のプロフィールページに飛ばされる。
  # そうではなく、ログインを促しログインした後はその前に行こうとしていたページに飛ばす。


  # 記録しておいたURLもしくはデフォルト値にリダイレクト
  # SessionsControllerのcreateで呼び出される
  def redirect_back_or(default)
    redirect_to(session[:forwarding_url] || default)
    session.delete(:forwarding_url)
  end

  # アクセスしようとしたURLを覚えておく
  # request:アクセスした情報を取得:getかどうか？
  # getであればアクセスしようとしていたoriginal_urlをsessionハッシュに記録
  # users_controllerのeditとupdateの時に実行されるログインしてるか確認する
  # logged_in_userメソッドで実行される
  def store_location
    session[:forwarding_url] = request.original_url if request.get?
  end




  #------------------------------------------------------------
  # current_userに関する2つの目立たないバグ
  # https://railstutorial.jp/chapters/advanced_login?version=5.1#sec-two_subtle_bugs

  # 【1】ユーザーが同じサイトを複数のタブ（あるいはウィンドウ）で開いていた場合。
  # ユーザーが1つのタブでログアウトし、もう1つのタブで再度ログアウトするとエラーになる。
  # これは1度目のLog_outメソッドの実行でcurrent_userがnilになるために、forget(rurrent_user)
  # が失敗する。

  # 【2】違う種類のブラウザでログインしていた時のバグ。
  # Firefoxでログアウトし、Chromeではログアウトせずにブラウザを終了させ、再度Chromeで
  # 同じページを開くとこの問題が発生する。

  # ユーザーがFirefoxでログアウトすると、user.forgetメソッドによってremember_digestがnilになる。
  # この時点でlog_outメソッドによってユーザーIDが削除（session.delete(:user_id)
  # されるため、current_userメソッド内の以下の条件はfalseになる

  # if (user_id) = session[:user_id]

  # elsif (user_id = cookies.signed[user_id])

  # 上記の条件式の結果、期待通りに動き結果はnilになる。

  # 1方、Chromeを閉じた時、session[:user_id]はnilになる。これはブラウザを閉じた時
  # 全てのsession変数の有効期限が切れるため。
  # しかし、cookiesはブラウザに残り続けるため、Chromeを再起動すると、データベースから
  # ユーザーを見つけることができてしまう。

  # 結果として次のif文が評価される。
  # user && user.outhenticated?(cookies[:remember_token])

  # この時userがnilであれば1番目の条件式で終了するが、実際にはnilではないので、2番目
  # の条件式まで評価が進み、ここでエラーが発生する。
  # 原因はFirefoxでログアウトした時、ユーザーのremember_digestを削除しているから。

  # すなわち、remember_digestがnilになるので、bcryptライブラリで例外が発生する。
  # この問題を解決するにはremember_digestが存在しない時falseを返す処理を、
  # authenticated?メソッドに追加する。




end
