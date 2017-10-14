class User < ApplicationRecord


  attr_accessor :remember_token, :activation_token

  before_save :downcase_email
  before_create :create_activation_digest

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  validates :name ,
    presence: true ,
    length: { maximum: 50}
  validates :email,
    presence: true ,
    length: { maximum: 255},
    format: { with: VALID_EMAIL_REGEX},
    uniqueness: { case_sensitive: false}

    # - save securely hashed password_digest attribute to the database
    # - generate password and password_confirmation virtual attributes
    # - generate authenticate method
  has_secure_password
  validates :password,
    presence: true,
    length: { minimum: 6 },
    allow_nil: true


  # The method BCrypt::Password.create uses salt to generate the hash,
  # so each time User.digest('string') is called, a different hash is returned
  # even if the same string is passed as argument.
  # To compare a string with the hash, you should call something like this:
  #   BCrypt::Password.new(string_hash).is_password?(plain_string)
  # Compare string_hash with the return of User.digest(plain_string) using ==
  # won't work
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                   BCrypt::Engine.cost
    BCrypt::Password.create( string, cost: cost)
  end

  def User.new_token
    SecureRandom.urlsafe_base64
  end

  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest , User.digest(self.remember_token))
  end

  # if try call BCrypt method passing a nil argument will raise a exception
  def authenticated?(attribute, token)
    digest = self.send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  def forget
    update_attribute(:remember_digest , nil)
  end

  def activate
    update_attribute(:activated , true)
    update_attribute(:activated_at, Time.zone.now)
  end

  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  private

    def downcase_email
      self.email = email.downcase
    end

    def create_activation_digest
      self.activation_token = User.new_token
      self.activation_digest = User.digest(activation_token)
    end

end
