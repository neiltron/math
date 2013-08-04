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
        TransactionalEmail.send_confirmation(user)

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
  end
end