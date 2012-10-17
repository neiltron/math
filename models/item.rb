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

    require 'pp'
    data = self.records.map_reduce(map, reduce).out(inline: 1).map do |item|
      [DateTime.parse(item['_id']).to_i, item['value']]
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
      [item['_id'].to_i, item['value']]
    end
  end
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