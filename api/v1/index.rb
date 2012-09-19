require 'rubygems'
require 'bundler/setup'

%w{
  grape garner json date uri mongoid boxer
}.each do |lib|
  require lib
end

module Doctothorpem
  class API < Grape::API
    use Garner::Middleware::Cache::Bust
    helpers Garner::Mixins::Grape::Cache

    version '1'
    prefix 'api'

    helpers do
      def current_user
        accesskey = AccessKey.find_by_token(params[:accesskey])

        accesskey.nil? ? false : accesskey.user
      end

      def authenticate!
        error!('401 Unauthorized', 401) unless current_user
      end
    end

    resource :users do
      before{ authenticate! }

      get do
        error!('401 Unauthorized', 401) unless current_user.is_admin

        User.all.map do |user|
          Boxer.ship(:user, user)
        end
      end

      resource ':user_id' do
        before do
          @user = User.where( :_id => params[:user_id] ).first

          error!('401 Unauthorized', 401) unless current_user == @user || current_user.is_admin
        end

        get do
          Boxer.ship(:user, @user)
        end

        resource :items do
          get do
            @user.items.map do |item|
              Boxer.ship(:item, item)
            end
          end
        end

        resource :records do
          get do
            @user.items.map do |item|
              item.records.map do |record|
                Boxer.ship(:record, record)
              end
            end
          end

          post do
            item = Item.find_or_create_by( :name => params[:item_name].downcase )
            @user.items.push item unless @user.items.include? item

            record = Record.create!( :amount => params[:amount], :user => current_user, :item => item )
            invalidate( User, current_user.id.to_s )

            Boxer.ship(:record, record)
          end
        end
      end
    end
  end
end