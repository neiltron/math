require 'mongoid'
require 'boxer'
require 'pony'

class User
	include Mongoid::Document
	include Mongoid::Timestamps
	include Mongoid::Paranoia
  include OAuth2::Model::ResourceOwner
  include OAuth2::Model::ClientOwner

	field :name, :type => String
  field :email, :type => String
  field :password_hash, :type => String
  field :confirmed, :type => Boolean
  field :confirm_token, :type => String
	field :last_update, :type => String
  field :items_updated_at, :type => DateTime
  field :password_salt, :type => String

	index({ :email => 1 }, { :unique => true })

	has_one :accesskey, :class_name => 'AccessKey'
	has_many :items
  has_many :categories

  before_create :process_on_create
  after_save :encrypt_pass

  #add username method to appease oath2-provider gem
  def username
    name
  end

  def authenticated? (password)
    self.password_hash == encrypt(password)
  end

  def self.authenticate (email = nil, password = nil, accesskey = nil)
    user = User.where( :email => email.downcase ).first
    user = nil unless user.nil? || user.authenticated?(password)

    if user.nil?
      if accesskey.nil?
        false
      else
        key = AccessKey.find_by_token(accesskey)

        if key.nil?
          false
        else
          user = key.user
        end
      end
    else
      user.remembered_pass! if !user.confirm_token.nil? #clear confirm token if user has logged in
    end

    #give user an access key if they don't have one. this should only really happen on first login
    if !user.nil? && user.accesskey.nil?
      user.accesskey = AccessKey.new
      user.accesskey.save
      user.save

      user.accesskey.reset if user.accesskey.expires.to_i <= Time.new.to_i || user.accesskey.expires.nil?
    end

    user || nil
  end

  def send_confirmation
    subject = 'Signup confirmation'
    body = "You recently signed up for Math. <br><br><a href='http://" + ENV['MATH_DOMAIN'] + "/confirm?key=" + self.confirm_token + "'>Click here to confirm your account</a>."

    Pony.mail :to => email,
              :from => 'no-reply@' + ENV['MATH_DOMAIN'],
              :subject => subject,
              :body => body,
              :headers => { 'Content-Type' => 'text/html' },
              :via => :smtp,
              :via_options => PONY_CONFIG
  end

  def send_forgot_pass_email
    subject = 'Forgot password'
    body = "Someone used the forgot password form at Math. <br><br><a href='http://" + ENV['MATH_DOMAIN'] + "/resetpw?key=" + self.confirm_token + "'>Click here to change your password</a>."

    Pony.mail :to => email,
              :from => 'no-reply@' + ENV['MATH_DOMAIN'],
              :subject => subject,
              :body => body,
              :headers => { 'Content-Type' => 'text/html' },
              :via => :smtp,
              :via_options => PONY_CONFIG
  end

  def confirm!
    self.confirmed = true
    self.save
  end

  def forgot_pass!
    self.confirm_token = new_token
    self.save
  end

  def remembered_pass!
    self.confirm_token = nil?
    self.save
  end

  def encrypt_pass
    unless self.password.nil?
      self.password_hash = encrypt(self.password)
      self.password = nil

      self.save
    end
  end

  def process_on_create
    encrypt_pass

    self.confirm_token = new_token
  end

  protected

  def salt
    if password_salt.nil? || password_salt.empty?
      secret    = Digest::SHA1.hexdigest("--#{Time.now.utc}--")
      self.password_salt = Digest::SHA1.hexdigest("--#{Time.now.utc}--#{secret}--")
    end
    password_salt
  end

  def encrypt(string)
    Digest::SHA1.hexdigest("--#{salt}--#{string}--")
  end

  def new_token
    encrypt("--#{Time.now.utc}--")
  end
end

Boxer.box(:user) do |box, user|
  box.view(:base) do
    {
      :id => user.id.to_s,
      :name => user.name
    }
  end
end