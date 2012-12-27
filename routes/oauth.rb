module Math
  class Web < Sinatra::Application
    #================================================================
    # Register applications

    get '/oauth/apps/new' do
      @client = OAuth2::Model::Client.new
      haml :'clients/new_client'
    end

    get '/oauth/apps/:id' do
      @client = OAuth2::Model::Client.find(params[:id])
      @client_secret = session[:client_secret]
      haml :'clients/show_client'
    end

    get '/oauth/apps/:id/edit/?' do
      @client = OAuth2::Model::Client.find(params[:id])
      haml :'clients/edit_client'
    end

    post '/oauth/apps' do
      @client = OAuth2::Model::Client.new(params)
      @client.owner = current_user

      if @client.save
        session[:client_secret] = @client.client_secret
        redirect("/oauth/apps/#{@client.id}")
      else
        haml :'clients/new_client'
      end
    end

    get '/developer' do
      @clients = OAuth2::Model::Client.where( :oauth2_client_owner => current_user.id.to_s )

      haml :'clients/list_clients'
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
end