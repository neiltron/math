require 'rubygems'
require 'bundler/setup'

%w{
  sinatra sinatra/assetpack haml bson mongoid json boxer mongoid_taggable_with_context rack-flash oauth2/provider
}.each do |lib|
  require lib
end


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

    register Sinatra::AssetPack
    enable :methodoverride

    helpers do
      def current_user
        User.where( :email => session[:uid] ).first
      end
    end

    assets {
      serve '/js',     from: 'public/js'        # Default
      serve '/css',    from: 'public/css'       # Default
      serve '/img',    from: 'public/img'    # Default

      # The second parameter defines where the compressed version will be served.
      # (Note: that parameter is optional, AssetPack will figure it out.)
      # The final parameter is an array of glob patterns defining the contents
      # of the package (as matched on the public URIs, not the filesystem)
      js :app, '/js/app.js', [
        '/js/zepto.min.js',
        '/js/FastClick.js',
        '/js/d3.v2.min.js',
        '/js/nv.d3.js',
        '/js/keymaster.min.js'
      ]

      css :app, '/css/app.css', [
        '/css/style.css',
        '/css/nv.d3.css'
      ]

      js_compression  :jsmin    # :jsmin | :yui | :closure | :uglify
      css_compression :simple   # :simple | :sass | :yui | :sqwish
    }

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
      @records = @category.records

      #return embeddable-specific layout if embed=1
      if params[:embed]
        haml :category_embed, :locals => { board: @category }
      else
        haml :category
      end
    end
  end

  require_relative 'models/init'
  require_relative 'routes/oauth'
  require_relative 'routes/signin'
  require_relative 'routes/signup'
end