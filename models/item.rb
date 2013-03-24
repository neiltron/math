require 'mongoid'
require 'boxer'

require 'haml'
require 'date'
require 'active_support/all'

class Item
	include Mongoid::Document
	include Mongoid::Timestamps
	include Mongoid::Paranoia

	field :name, :type => String
  field :display_frequency, :type => String, :default => 'daily'
  field :display_type, :type => String, :default => 'total'
  field :privacy, :type => Boolean, :default => false

	has_many :records
	belongs_to :user, :touch =>  true
  belongs_to :category, :touch =>  true

  def pricy?
    !!privacy
  end

  def get_records
    if display_type == 'total'
      self.records_total_daily
    elsif display_type == 'average'
      self.records_avg_daily
    end
  end

  def records_total_daily
    map = <<-EOS
      function() {
        var value = Math.floor(parseFloat(this.amount, 10) * 10) / 10,
            timestamp = this.created_at,
            month = ("0" + (timestamp.getUTCMonth() + 1)).slice(-2),
            day = ("0" + (timestamp.getDate() + 1)).slice(-2),
            date = timestamp.getUTCFullYear() + "-" +  month + "-" + day;

        emit(date, value)
      }
    EOS
    reduce = <<-EOS
      function(key, values) {
        var count = 0;
        values.forEach(function(value) {
          count += value;
        });
        return(count);
      }
    EOS

    data = {}

    self.records.map_reduce(map, reduce).out(inline: 1).each do |item|
      data[item['_id']] = item['value']
    end

    1.month.ago.to_date.upto(Date.tomorrow.to_date).map do |date|
      [date.to_datetime.to_i, (data[date.to_s] || 0)]
    end
  end

  def records_avg_daily
    map = <<-EOS
      function() {
        var value = Math.floor(parseFloat(this.amount, 10) * 10) / 10,
            timestamp = parseInt(new Date(this.created_at).getTime(), 10);

        emit(timestamp,  value)
      }
    EOS
    reduce = <<-EOS
      function(key, values) {
        var total = 0,
            count = values.length;

        values.forEach(function(value) {
          total += value;
        });
        return(total / count);
      }
    EOS

    self.records.map_reduce(map, reduce).out(inline: 1).map do |item|
      [item['_id'].to_i / 1000, item['value']]
    end
  end
end


embed_template = File.read(File.join(settings.views, 'item_embed.haml'))

Boxer.box(:item) do |box, item, viewer, opts|
  box.view(:base) do
    {
      :id => item.id.to_s,
      :name => item.name,
      :display_type => item.display_type,
      :display_frequency => item.display_frequency
    }
  end

  box.view(:oembed) do
    html = Haml::Engine.new(embed_template).render(Object.new, { item: item, records: opts[:records] })
    escaped_html = Haml::Helpers.html_escape html

    {
      type: 'rich',
      version: '1.0',
      title: item.name,
      provider_name: 'Math',
      provider_url: 'http://www.mathematics.io',
      html: escaped_html,
      width: 400,
      height: 300
    }
  end
end