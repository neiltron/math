module Math
  class Items < Grape::API
    format :json

    resource :items do
      desc 'Get all items belonging to the specified user'
      get do
        @user.items.order_by([[:updated_at, :desc]]).map do |item|
          Boxer.ship(:item, item)
        end
      end

      desc 'Update the specified item'
      params do
        requires :id, type: String, desc: 'Item ID'
      end
      put ':id' do
        item = Item.find(params[:id])

        item.display_type = params[:display_type] unless params[:display_type].nil?
        item.display_frequency = params[:display_frequency] unless params[:display_frequency].nil?
        item.privacy = params[:privacy] unless params[:privacy].nil?

        item.save
      end

      resource ':id/records' do
        desc 'Get all records for the specified item'
        get do
          per = (params[:per] || 7).to_i
          page = (params[:page] || 0).to_i
          item = Item.find(params[:id])

          if item.display_type == 'total'
            records = item.records_total_daily
          elsif item.display_type == 'average'
            records = item.records_avg_daily
          end

          { values: records.to_a }
        end

        desc 'Delete a record'
        delete ':record_id' do
          record = Record.find(params[:record_id])
          record.delete
        end
      end
    end
  end
end