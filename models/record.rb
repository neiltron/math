require 'mongoid'
require 'boxer'

class Record
	include Mongoid::Document
	include Mongoid::Timestamps
	include Mongoid::Paranoia
	
	field :amount, :type => Float

	belongs_to :item
end
  
Boxer.box(:record) do |box, record|
  box.view(:base) do
    {
      :id => record.id.to_s,
      :item => record.item.id.to_s,
      :amount => record.amount,
      :timestamp => record.created_at.to_i
    }
  end
end