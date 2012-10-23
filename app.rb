require 'rubygems'
require 'bundler/setup'

%w{
  sinatra haml bson mongoid json mongoid_taggable_with_context warden rack-flash
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

    get '/item/:id' do
      redirect '/login' if session[:accesskey].nil?

      @user = current_user
      @item = Item.find(params[:id])

      if @item.display_type == 'total'
        @records = @item.records_total_daily
      elsif @item.display_type == 'average'
        @records = @item.records_avg_daily
      end

      #return embeddable-specific layout if embed=1
      if params[:embed]
        haml :item_embed
      else
        haml :item
      end
    end
  end

  require_relative 'models/init'
  require_relative 'routes/users'
end