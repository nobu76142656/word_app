class User < ApplicationRecord
  attr_accessor :remember_token, :activation_token
  before_save :downcase_email
  before_create :create_activation_digest
  validates :name,  presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
            format: { with: VALID_EMAIL_REGEX },
            uniqueness: { case_sensitive: false }

  # tips
  # has_secure_password：
  # ・ハッシュ化したパスワードを、password_digestに保存できるようになる。
  # ・2つのペアの仮想的（DBに存在しない)な属性のpasswordとpassword_confirmation
  # が使えるようになる。
  # ・authenticateメソッドが使えるようになる。
  # ・機能させるにはpassword_digest属性がモデル内に必要。
  # digestにはハッシュ化（元に戻せないので暗号化ではない）されたpasswordが入る。

  has_secure_password
  validates :password, presence: true, length: { minimum: 6}, allow_nil: true

  # 渡された文字列のハッシュ値を返す
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # ランダムなトークンを返す
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  # 永続セッションのためにユーザーをデータベースに記憶する
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  # tips
  # ユーザーの暗号化済みIDと記憶トークンをブラウザの永続cookiesに保存する。
  # cookiesメソッドを使う。このメソッドはsessionと同様、ハッシュとして使える。
  # cookiesはvalueとオプションのexpires(有効期限)からできている。
  # remember_tokenと同じ値をcookiesに保存することで永続的なセッションを作る。
  # user.idのcookiesへの保存はsignedを使い署名つきにする。
  # ユーザーIDと記憶トークンはペアで扱う必要があるので、user.idを保存するcookiesも永続化する。
  # cookies.signed[user_id]で自動的にユーザーIDの暗号が解除されてfind_byで使えるようになる。
  # 次にbcryptを使って、cookies[:remember_token]とremrmber_digestが一致することを確認。
  # cookies[:remember_token]は暗号化されたユーザーIDと共にブラウザに20年保存。
  # ブラウザに保存されたremember_tokenとremember_digestを比較する。
  # has_secure_passwordで提供されているauthenticateメソッドと似ている。

  # 渡されたtokenがdigestと一致したらtrueを返す
  # ここでのremember_tokenはアクセラのremember_tokenとは別のローカル変数。
  # def authenticated?(remember_token)
  #   # digestが存在しない場合は処理を終了
  #   return false if remember_token
  #   BCrypt::Password.new(remember_digest).is_password?(remember_token)
  # end

  # 11.3.1 authenticated?メソッドの抽象化のために上記メソッドを改良
  def authenticated?(attribute, token)
    # digestが存在しない（nil）の場合(2つのブラウザで片方でログアウトした時など)
    # falseを返す。returunで即座にメソッドを終了している。
    
    # sendを使って抽象化
    digest = send("#{attribute}_digest")
    
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  # ユーザーのログイン情報を破棄する
  def forget
    update_attribute(:remember_digest, nil)
  end

  # アカウントを有効にする
  def activate
    update_columns(activated: true, activated_at: Time.zone.now)
  end

  # 有効化用のメールを送信する
  def send_activation_email
    # UserMailer.account_activation(self).deliver_now
    # チュートリアル通りの上記の書き方ではメール文が（日本語？）base64でエンコーディングされて
    # しまった。
    # cloud9ではこのような現象は起きなかった。

    # メール送信でエラーが出る時
    # Content-Transfer-Encoding: base64 となってしまう時
    # http://d.hatena.ne.jp/takahashim/20101201/p1

    mail = UserMailer.account_activation(self)
    mail.transport_encoding = "8bit"
    mail.deliver
  end

  private
    # メールアドレスを全て小文字にする
    def downcase_email
      self.email = email.downcase
    end

    # activation_tokenとacitvation_digestを作成し、代入する。
    def create_activation_digest
      self.activation_token  = User.new_token
      self.activation_digest = User.digest(activation_token)
    end

end

# tips
# 11.3.1 authenticated?メソッドの抽象化
#
# activation_tokenとemailをそれぞれparams[:id]とparams[:email]として参照できる。
# activation_tokenは、
# http://www.example.com/account_activations/q5lt38hQDc_959PVoo6b7A/edit
# としてidのように扱われているために、params[:id]として参照できる。
#
# 次のようなコードでユーザーを検索して認証する。
# user = User.find_by(email: params[:email])
# if user && user.authenticated?(:activation, params[:id])
# 
# 上のコードで使っているauthenticated?メソッドはアカウント有効化のdigestと渡されたtokenが
# （引数:activationにdigestを渡す）一致するかを検証する。
# ただし、この下記メソッドはremember_tokenようなのでactivationでは使えない。

# tokenがdigestと一致したらtrueを返す

# def authenticated?(remember_token)
#   return false if remember_digest.nil?
#   BCrypt::Password.new(remember_digest).is_password?(remember_token)
# end

# BCryptを使ってcookies[:remember_token]がremember_digestと一致するか確認。
# is_password?は==の再定義。一致しているか確認している。

# remember_digestはUserモデル属性なので、モデル内では
# self.remember_digest と書ける。

# 上記コードのrememberの部分を変数として扱いたい。状況に応じて切り替えたい。

#
# 受け取ったパラメータに応じて呼び出すメソッドを切り替える手法を使う。【メタプログラミング】
#

# railsコンソールを開き、Rubyオブジェクトに対してsendメソッドを実行して配列の長さを取るとする
# a = [1, 2, 3]
# a.length
# =>3
# a.send(:length)
# =>3
# a.send("length")
# =>3

# この時sendを通して渡したシンボル:lengthや文字列"length"はいずれもlenghtメソッドと同じ
# 結果となる。どちらもオブジェクトにlengthメソッドを渡しているため等価。

# もう一つの例
# user = User.first
# user.activation_digest
# =>"$2a$10$4e6TFzEJAVNyjLv8Q5u22ensMt28qEkx0roaZvtRcp6UZKR
# user.send(:activation_digest)
# =>"$2a$10$4e6TFzEJAVNyjLv8Q5u22ensMt28qEkx0roaZvtRcp6UZKR
# user.send("activation_digest")
# =>"$2a$10$4e6TFzEJAVNyjLv8Q5u22ensMt28qEkx0roaZvtRcp6UZKR
# attribute = :acrivation
# user.send("#{attribute}_digest")
# =>"$2a$10$4e6TFzEJAVNyjLv8Q5u22ensMt28qEkx0roaZvtRcp6UZKR

# 文字列の式展開によって引数を組み立てsendに渡している。

# 文字列'activation'でも同じことができるが、Rubyではシンボルを使う方が一般的。

#
# sendメソッドの動作原理がわかったので、これを使ってauthenticated?メソッドを書き換える。
#

# def authenticated?(remember_token)
#   digest = self.send("remember_digest")
#   return false if digest.nil?
#   BCrpt::Password.new(digest).is_password?(remember_token)
# end

# 上記コードの各引数を一般化し、文字列を式展開する。sendの前のselfは省略できる。
# def authenticated?(attribute, token)
#   digest = send("#{attribute}_digest")
#   return false if digest.nil?
#   BCrypt::Password.new(digest).is_password?(token)
# end


