#/////////////////
#////        USERS
#/////////////////

module Math
  class Web < Sinatra::Application
    get '/signup/?' do
      haml :'users/signup/form'
    end

    post '/signup' do
      user = User.where( :email => params[:email].downcase.strip ).first

      if user.nil?
        user = User.new( :email => params[:email].downcase.strip )

        %w{ password name }.each do |param|
          user.attributes[param] = params[param.to_sym].strip unless params[param.to_sym].nil?
        end

        user.save
        user.send_confirmation

        haml :'users/signup/confirmation_sent'
      else
        flash[:error] = 'A user with that email address already exists. If you already have an account, please use the <a href="/forgot">forgot password</a> form.'

        haml :'users/signup/form'
      end
    end

    get '/confirm' do
      redirect '/' if params[:key].nil?

      user = User.where( :confirm_token => params[:key] ).first

      if user.nil?
        haml :'users/signup/confirm_fail'
      else
        user.confirm!

        flash[:notice] = 'Your account has been confirmed. You may now login.'
        redirect '/login'
      end
    end

    get '/terms/?' do
      haml :'users/signup/terms'
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
      user.send_forgot_pass_email

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

    get '/auth/failure/?' do
      haml :auth_failure
    end

    get '/login/?' do
      haml :login, { :layout => false }
    end

    post '/login/?' do
      user = User.authenticate(params['email'],params['password'],params['accesskey'])

      flash[:error] = 'Invalid username or password.'
      redirect '/login' if user.nil?

      if user
        session[:accesskey] = user.accesskey.token
        session[:uid] = user.email

        redirect '/'
      end

      haml :index
    end

    post '/unauthenticated/?' do
      status 401
      haml :login, { :layout => false }
    end

    get '/logout/?' do
      session[:uid] = nil
      session.clear
      redirect '/'
    end
  end
end
