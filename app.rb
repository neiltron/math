require 'rubygems'
require 'bundler/setup'

%w{
  sinatra haml bson mongoid json boxer mongoid_taggable_with_context warden rack-flash oauth2/provider
}.each do |lib|
  require lib
end

require 'pp'


module Math
  class Web < Sinatra::Application
    set :app_file, __FILE__
    set :root, File.dirname(__FILE__)
    set :public_folder,   File.expand_path(File.dirname(__FILE__) + '/public')
    set :server, 'thin'
    set :logging, true
    set :raise_errors, true
    set :haml, {:format => :html5 }
    set :protection, :except => :frame_options

    enable :methodoverride

    Warden::Manager.serialize_into_session { |user| user.id }
    Warden::Manager.serialize_from_session { |id| User.where( :_id => id).first }
    #Warden::Manager.before_failure { |env,opts| env['REQUEST_METHOD'] = "POST" }

    Warden::Strategies.add(:password) do
      def valid?
        params[:username] || params[:password]
      end

      def authenticate!
        user = User.authenticate( :email => params['email'], :password => params['password'] ).first
        user = AccessKey.find_by_token(session[:accesskey]).user if user.nil?

        user.accesskey.reset if user.accesskey.expires.to_i <= Time.new.to_i || user.accesskey.expires.nil?

        user.nil? ? fail!("Could not log in") : success!(user)
      end
    end

    use Warden::Manager do |manager|
      manager.default_strategies :password
      manager.failure_app = Math::Web
    end

    helpers do
      def current_user
        User.where( :email => session[:uid] ).first
      end
    end

    get '/' do
      redirect '/login' if session[:accesskey].nil?

      @user = current_user
      haml :index
    end

    get '/oembed/?' do
      path = URI(params[:url]).path.split('/') # => ["", "item", "<item_id>"]
      item_id = path[path.count - 1]

      @item = Item.find(item_id)

      Boxer.ship(:item, @item, current_user, { view: :oembed, records: @item.get_records }).to_json
    end

    get '/item/:id' do
      redirect '/login' if session[:accesskey].nil? && params[:embed].nil?

      @user = current_user
      @item = Item.find(params[:id])
      @records = @item.get_records


      #return embeddable-specific layout if embed=1
      if params[:embed]
        haml :item_embed, :locals => { item: @item, records: @records }
      else
        haml :item
      end
    end

    get '/categories/:id' do
      redirect '/login' if session[:accesskey].nil? && params[:embed].nil?

      @user = current_user
      @category = Category.find(params[:id])
      @records = @category.records.map do |record|

      end

      #return embeddable-specific layout if embed=1
      if params[:embed]
        haml :category_embed, :locals => { board: @category }
      else
        haml :category
      end
    end
  end

  require_relative 'models/init'
  require_relative 'routes/users'
  require_relative 'routes/oauth'
end