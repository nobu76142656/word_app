class User < ApplicationRecord
  before_save { self.email = email.downcase }
  validates :name,  presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
            format: { with: VALID_EMAIL_REGEX },
            uniqueness: { case_sensitive: false }

  # has_secure_password：
  # ・ハッシュ化したパスワードを、password_digestに保存できるようになる。
  # ・2つのペアの仮想的（DBに存在しない)な属性のpasswordとpassword_confirmation
  # が使えるようになる。
  # ・authenticateメソッドが使えるようになる。
  # ・機能させるにはpassword_digest属性がモデル内に必要。
  # digestにはハッシュ化（元に戻せないので暗号化ではない）されたpasswordが入る。
  has_secure_password
  validates :password, presence: true, length: { minimum: 6}

end
