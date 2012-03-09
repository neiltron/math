require 'mongoid_token'

class AccessKey
  include Mongoid::Document
	include Mongoid::Token
	
  field :expires, :type => DateTime
  token :length => 16, :contains => :alphanumeric

  belongs_to :user
  
  def reset
    token = nil
    expires = Time.new.to_i
    
    self.save
  end
end