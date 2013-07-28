module Math
  class V1 < Grape::API
    version '1'

    helpers do
      def current_user
        accesskey = AccessKey.where( :token => params[:accesskey]).first

        if accesskey.nil?
          accesskey = OAuth2::Model.find_access_token( params[:accesskey] )
          user = accesskey.nil? ? nil : accesskey.owner
        else
          user = accesskey.user
        end

        accesskey.nil? ? false : user
      end

      def authenticate!
        error!('401 Unauthorized', 401) unless current_user
      end
    end

    resource :users do
      before{ authenticate! }

      desc 'Get the profile for the current user'
      get 'profile' do
        Boxer.ship(:user, current_user)
      end

      resource ':user_id' do
        before do
          @user = User.where( :_id => params[:user_id] ).first

          error!('401 Unauthorized', 401) unless current_user == @user || current_user.is_admin
        end

        desc 'Get profile information for the specified user'
        params do
          requires :user_id, type: String, desc: 'User ID'
        end
        get do
          Boxer.ship(:user, @user)
        end

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

        resource :categories do
          desc 'Get all categories belonging to a user'
          get do
            categories = @user.categories.map do |category|
                Boxer.ship(:category, category)
            end

            {
              categories: categories
            }
          end

          desc 'Create a new category'
          params do
            requires :name, type: String, desc: 'Category name'
            optional :item_ids, desc: 'An list of items to be included in this category'
          end
          post do
            category = Category.create!( :name => params[:name] )

            #check for item existence, add to category
            params[:item_ids].each do |item_id|
              item = Item.find(item_id)
              category.items.push item unless item.nil?
            end unless params[:item_ids].nil?

            @user.categories.push category
            @user.save

            Boxer.ship(:category, category)
          end

          params do
            requires :category_id, desc: 'Category ID'
          end
          resource ':category_id' do
            before { @category = Category.find(params[:category_id]) }

            desc 'Get category information'
            get do
              Boxer.ship(:category, @category)
            end

            desc 'Update a category'
            put do
              @category.update_attributes!(params) if @category.user == current_user
            end

            desc 'Add items to a category'
            post 'items' do
              params[:items].each do |item_id|
                item = Item.find(item_id)
                @category.items.push item unless item.nil?
              end

              @category.save
            end

            desc 'Get all related records for a category'
            get 'records' do
              per = (params[:per] || 7).to_i
              page = (params[:page] || 0).to_i
              category = Category.find(params[:category_id])

              { values: category.records.to_a }
            end
          end
        end

        desc 'Create a new record'
        params do
          requires :item_name, type: String, desc: 'Item name'
          requires :amount, type: Float, desc: 'Record value'
        end
        post '/records' do
          item = Item.find_or_create_by( :name => params[:item_name].downcase )
          @user.items.push item unless @user.items.include? item

          record = Record.create!( :amount => params[:amount], :user => current_user, :item => item )
          item.touch

          Boxer.ship(:record, record)
        end
      end
    end
  end
end