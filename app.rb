require 'rubygems'
require 'bundler/setup'

%w{
  sinatra haml bson mongoid json mongoid_taggable_with_context warden rack-flash
}.each do |lib|
  require lib
end

require 'pp'


module Doctothorpem
  class Web < Sinatra::Application
    set :app_file, __FILE__
    set :root, File.dirname(__FILE__)
    set :public_folder,   File.expand_path(File.dirname(__FILE__) + '/public')
    set :server, 'thin'
    set :logging, true
    set :raise_errors, true
    set :haml, {:format => :html5 }

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
      manager.failure_app = Doctothorpem::Web
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
      @records = @item.records.map do |record|
        [record.created_at.to_i, record.amount.to_f] unless record.amount.nil?
      end

      pp @records

      haml :item
    end
  end

  require_relative 'models/init'
  require_relative 'routes/users'
end