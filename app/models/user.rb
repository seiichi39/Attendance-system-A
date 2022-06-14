class User < ApplicationRecord
  has_many :attendances, dependent: :destroy
  attr_accessor :remember_token
  before_save { self.email = email.downcase }

  validates :name,  presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 100 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: true
  validates :department, length: { in: 2..30 }, allow_blank: true
  validates :basic_time, presence: true
  validates :work_time, presence: true
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true
  
  # 渡された文字列のハッシュ値を返す。
  def User.digest(string)
    cost =
      if ActiveModel::SecurePassword.min_cost
        BCrypt::Engine::MIN_COST
      else
        BCrypt::Engine.cost
      end
    BCrypt::Password.create(string, cost: cost)
  end
  
  #ランダムなトークンを返す。
  def User.new_token
    SecureRandom.urlsafe_base64
  end
  
  #永続セッションのため、ハッシュ化したトークンをデータベースに記憶する。
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end
  
  #トークンがダイジェストと一致すればtrueを返す。
  def authenticated?(remember_token)
    return false if remember.digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end
  
  # ユーザーのログイン情報を破棄する。
  def forget
    update_attribute(:remember_digest, nil)
  end
  
  def self.search(search)
    if search
      where(['name LIKE ?', "%#{search}%"])
    else
      all
    end
  end

  def self.import(file)
    imported_num = 0

    open(file.path, 'r:cp932:utf-8', undef: :replace) do |f|
      csv = CSV.new(f, :headers => :first_row)
      csv.each do |row|
        next if row.header_row?

        table = Hash[[row.headers, row.fields].transpose]
        
        user = find_by(:id => table["id"])
        if user.nil?
          user = new
        end

        user.attributes = table.to_hash.slice(
                    *table.to_hash.except(:id, :created_at, :updated_at).keys)

        if user.valid?
          user.save!
          imported_num += 1
        end
      end
    end
    
    imported_num
  end
    
end