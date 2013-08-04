module ApiHelpers
  def current_user
    accesskey = AccessKey.where( :token => params[:accesskey]).first

    if accesskey.nil?
      accesskey = OAuth2::Model.find_access_token( params[:accesskey] )
      user = accesskey.nil? ? nil : accesskey.owner
    else
      user = accesskey.user
    end

    accesskey.nil? ? false : user
  end

  def authenticate!
    error!('Unauthorized', 401) unless current_user
  end
end