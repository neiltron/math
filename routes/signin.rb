module Math
  class Web < Sinatra::Application
    get '/login/?' do
      haml :login, { :layout => false }
    end

    post '/login/?' do
      user = User.authenticate(params['email'],params['password'])

      if user
        session[:accesskey] = user.accesskey.token
        session[:uid] = user.email

        redirect '/'
      else
        flash[:error] = 'Invalid username or password.'
        redirect '/login'
      end
    end

    get '/logout/?' do
      session[:uid] = nil
      session.clear

      redirect '/'
    end

    get '/auth/failure/?' do
      haml :auth_failure
    end

    post '/unauthenticated/?' do
      status 401
      haml :login, { :layout => false }
    end

    get '/forgot' do
      haml :'users/forgot_pass'
    end

    post '/forgot' do
      user = User.where( :email => params[:email] ).first

      if user.nil?
        flash[:error] = "No account could be found with that email address."
        redirect '/forgot'
      end

      user.forgot_pass!
      TransactionalEmail.send_forgot_pass_email(user)

      haml :'users/forgot_pass_sent'
    end

    get '/resetpw/?' do
      user = User.where( :confirm_token => params[:key] ).first

      if user.nil?
        flash[:error] = "The confirmation token you've used is either invalid or has expired. Please try resetting your password again."
        redirect '/login'
      end

      haml :'users/reset_password'
    end

    post '/resetpw/?' do
      user = User.where( :confirm_token => params[:key] ).first

      if user.nil?
        flash[:error] = "The confirmation token you've used is either invalid or has expired. Please try resetting your password again."
        redirect '/login'
      end

      user.password = params[:password] if params[:password] == params[:confirm_password] && params[:password] != ''
      user.save

      flash[:notice] = "Your password has been successfully reset. You may now login."
      redirect '/login'
    end
  end
end
