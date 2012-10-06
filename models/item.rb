require 'mongoid'
require 'boxer'

class Item
	include Mongoid::Document
	include Mongoid::Timestamps
	include Mongoid::Paranoia

	field :name, :type => String
  field :display_frequency, :type => String, :default => 'daily'
  field :display_type, :type => String, :default => 'total'

	has_many :records
	belongs_to :user, :touch =>  true
end

Boxer.box(:item) do |box, item|
  box.view(:base) do
    {
      :id => item.id.to_s,
      :name => item.name,
      :display_type => item.display_type,
      :display_frequency => item.display_frequency
    }
  end
end