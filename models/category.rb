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
    items.map do |item|
      { values: item.records.map { |record| [record.created_at.to_i, record.amount] } }
    end
  end
end

# embed_template = File.read(File.join(settings.views, 'category_embed.haml'))

Boxer.box(:category) do |box, category|
  box.view(:base) do
    {
      :id => category.id.to_s,
      :name => category.name,
      :item_ids => category.items.map { |item| item.id.to_s }
    }
  end

  # box.view(:oembed) do
  #   html = Haml::Engine.new(embed_template).render(Object.new, { category: category, items: category.items })
  #   escaped_html = Haml::Helpers.html_escape html

  #   {
  #     type: 'rich',
  #     version: '1.0',
  #     title: category.name,
  #     provider_name: 'Math',
  #     provider_url: 'http://www.mathematics.io',
  #     html: escaped_html,
  #     width: 400,
  #     height: 300
  #   }
  # end
end