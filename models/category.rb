require 'mongoid'
require 'boxer'

require 'haml'
require 'date'
require 'active_support/all'

class Category
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia

  field :name, :type => String
  field :privacy, :type => Boolean, :default => false

  has_many :items
  belongs_to :user, :touch =>  true

  def privacy?
    !!privacy
  end

  def records
    items.order_by([[:updated_at, :desc]]).map do |item|
      { key: item.name, values: item.get_records }
    end
  end
end

Boxer.box(:category) do |box, category|
  box.view(:base) do
    {
      :id => category.id.to_s,
      :name => category.name,
      :item_ids => category.items.map { |item| item.id.to_s }
    }
  end
end