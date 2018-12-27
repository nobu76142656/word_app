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
    UserMailer.account_activation(self).deliver_now
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


