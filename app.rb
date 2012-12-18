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

      if @item.display_type == 'total'
        records = item.records_total_daily
      elsif @item.display_type == 'average'
        records = item.records_avg_daily
      end

      Boxer.ship(:item, @item, current_user, { view: :oembed, records: records }).to_json
    end

    get '/item/:id' do
      redirect '/login' if session[:accesskey].nil? && params[:embed].nil?

      @user = current_user
      @item = Item.find(params[:id])

      if @item.display_type == 'total'
        @records = @item.records_total_daily
      elsif @item.display_type == 'average'
        @records = @item.records_avg_daily
      end

      #return embeddable-specific layout if embed=1
      if params[:embed]
        haml :item_embed, :locals => { item: @item, records: @records }
      else
        haml :item
      end
    end

    #================================================================
    # Register applications

    get '/oauth/apps/new' do
      @client = OAuth2::Model::Client.new
      haml :'clients/new_client'
    end

    post '/oauth/apps' do
      @client = OAuth2::Model::Client.new(params)
      if @client.save
        session[:client_secret] = @client.client_secret
        redirect("/oauth/apps/#{@client.id}")
      else
        haml :'clients/new_client'
      end
    end

    get '/oauth/apps/:id' do
      @client = OAuth2::Model::Client.find(params[:id])
      @client_secret = session[:client_secret]
      haml :'clients/show_client'
    end


    #================================================================
    # OAuth 2.0 flow

    # Initial request exmample:
    # /oauth/authorize?response_type=token&client_id=7uljxxdgsksmecn5cycvug46v&redirect_uri=http%3A%2F%2Fexample.com%2Fcb&scope=read_notes
    [:get, :post].each do |method|
      __send__ method, '/oauth/authorize' do
        @user = current_user
        @oauth2 = OAuth2::Provider.parse(@user, env)
        @page = 'oauth'

        if @oauth2.redirect?
          redirect @oauth2.redirect_uri, @oauth2.response_status
        end

        headers @oauth2.response_headers
        status  @oauth2.response_status

        haml(@user ? :authorize : :login)
      end
    end

    post '/oauth/login' do
      @user = User.authenticate(params['email'],params['password'])

      unless @user.nil?
        session[:accesskey] = @user.accesskey.token
        session[:uid] = @user.email
      end

      @oauth2 = OAuth2::Provider.parse(@user, env)
      @page = 'oauth'

      haml(@user ? :authorize : :login)
    end

    post '/oauth/allow' do
      @user = current_user
      pp @user
      @auth = OAuth2::Provider::Authorization.new(@user, params)
      @page = 'oauth'

      if params['allow'] == '1'
        @auth.grant_access!
      else
        @auth.deny_access!
      end
      redirect @auth.redirect_uri, @auth.response_status
    end
  end

  require_relative 'models/init'
  require_relative 'routes/users'
end