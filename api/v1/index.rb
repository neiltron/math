require_relative 'items'
require_relative 'categories'
require_relative 'helpers'

module Math
  class V1 < Grape::API
    version '1'

    helpers ApiHelpers

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

        mount ::Math::Items
        mount ::Math::Categories
      end
    end
  end
end