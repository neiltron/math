require 'mongoid'
require 'boxer'

class User
	include Mongoid::Document
	include Mongoid::Timestamps
	include Mongoid::Paranoia
	
	field :name, :type => String
  field :email, :type => String
  field :password_hash, :type => String
  field :confirmed, :type => Boolean
  field :confirm_token, :type => String
	field :last_update, :type => String
  field :password_salt, :type => String
	
	index :email, :unique => true
	
	has_one :accesskey, :class_name => 'AccessKey'
	has_many :items
	
  before_create :process_on_create
  
  def authenticated? (password)
    self.password_hash == encrypt(password)
  end
  
  def self.authenticate (email = nil, password = nil, accesskey = nil)
    user = User.where( :email => email.downcase ).first
    user = nil unless user.nil? || user.authenticated?(password)

    if user.nil?
      key = AccessKey.find_by_token(accesskey)

      if key.nil?
        false
      else
        user = key.user
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
    Resque.enqueue(WorkHQ::SignupConfirmation, self.id.to_s)
  end
  
  def send_forgot_pass_email
    Resque.enqueue(WorkHQ::ForgotPassEmail, self.id.to_s)
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

  def process_on_create
    self.password_hash = encrypt(self.password)
    self.password = nil
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
      :id => user.id.to_s
      :name => user.name
    }
  end
end