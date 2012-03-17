require 'mongoid'
require 'boxer'

class Item
	include Mongoid::Document
	include Mongoid::Timestamps
	include Mongoid::Paranoia
	
	field :name, :type => String

	has_many :records
	belongs_to :user
end
  
Boxer.box(:item) do |box, item|
  box.view(:base) do
    {
      :id => item.id.to_s,
      :name => item.name
    }
  end
end