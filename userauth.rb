require 'time'
require 'net/http'
require 'uri'
require 'json'
require 'data_mapper'
require 'google/api_client'
require 'jwt'


def api_client; settings.api_client; end
    


get '/login' do
    # Ensure user has authorized the app
    unless (user_credentials.access_token != nil && session[:googleemail] != nil && session[:google_unique] != nil) || request.path_info =~ /^\/oauth2/
        #redirect 'http://ming-testing.herokuapp.com/oauth2authorize'
        redirect '/oauth2authorize'
    end
    
    redirect '/'
end

get '/logout' do
    session[:googleemail] = nil
    session[:google_unique] = nil
    user_credentials.access_token = nil
    
    redirect '/'
end

get '/oauth2authorize' do
    # Request authorization
    redirect user_credentials.authorization_uri.to_s, 303
end

get '/oauth2callback' do
    puts "=================="
    puts params
    puts params[:code]
    
    if params[:code] != nil
        user_credentials.code = params[:code]
    end
    
    puts user_credentials.code
    
    # Exchange token
    #user_credentials.code = params[:code] if params[:code]
    user_credentials.fetch_access_token!
    
    puts user_credentials.code
    puts user_credentials.access_token
    puts user_credentials.refresh_token
    puts "ID TOKEN"
    puts user_credentials.id_token
    google_id_hash = JWT.decode(user_credentials.id_token, nil, nil)
    puts google_id_hash
    puts google_id_hash['email']
    
    session[:access_token] = user_credentials.access_token
    session[:refresh_token] = user_credentials.refresh_token
    session[:expires_in] = user_credentials.expires_in
    session[:issued_at] = user_credentials.issued_at
    session[:googleemail] = google_id_hash['email']
    session[:google_unique] = google_id_hash['sub']
    
    #Creating user in DB
    create_user(session[:google_unique], session[:googleemail])
    
    user_alias = get_user_alias(session[:google_unique])
    if user_alias != nil
        session[:useralias] = user_alias
    else
        session[:useralias] = session[:googleemail]
    end
        
    
    params[:code]
    redirect '/'
end




def user_configure
    client = Google::APIClient.new
    client.authorization.client_id = '102824958333-1jk2b0mn8dscu44qjloa8es5g6v0bl7k.apps.googleusercontent.com'
    client.authorization.client_secret = '7d10PS91E78hzki_xRZC1ofF'
    #client.authorization.scope = 'https://www.googleapis.com/auth/youtube'
    client.authorization.scope = 'https://www.googleapis.com/auth/userinfo.email'
    
    youtube = client.discovered_api('youtube', 'v3')

    set :api_client, client
    #set :youtube, youtube
end


def user_credentials
  # Build a per-request oauth credential based on token stored in session
  # which allows us to use a shared API client.
  @authorization ||= (
    auth = api_client.authorization.dup
    #auth.redirect_uri = 'http://ming-testing.herokuapp.com/oauth2callback'
    auth.redirect_uri = settings.current_url + 'oauth2callback'
    #auth.response_type = 'code'
    #auth.client_id = '102824958333'
    auth.update_token!(session)
    auth
  )
end

#Return nil if not logged in
def get_user_info()
    return_map = nil
    if session[:google_unique] != nil && user_credentials.access_token != nil
        return_map = {}
        return_map['email'] = session[:googleemail]
        return_map['sub'] = session[:google_unique]
        return_map['useralias'] = session[:useralias]
    end
    return return_map
end