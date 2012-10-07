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
        var timestamp = this.created_at.getFullYear() + '-' + this.created_at.getMonth() + '-' + this.created_at.getDate();
        emit(timestamp, this.amount)
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

    self.records.map_reduce(map, reduce).out(inline: 1).map do |item|
      [item['_id'].to_datetime.to_i, item['value']]
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