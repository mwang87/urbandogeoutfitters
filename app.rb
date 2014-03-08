require 'sinatra'
require 'data_mapper'
require './models'
require './userauth'
require './usercontroller'
require './ratinghelper'

user_configure();

enable :sessions
set :session_secret, 'super secret2'

get "/" do
    @user_info = get_user_info()
    
    @comparison_pictures = get_random_comparison_pictures()
    
    erb :homepage
end


post "/upload" do
    @user_info = get_user_info()
    
    if @user_info == nil
        redirect '/login'
    end
    
    picture_url = params[:pictureURL]
    
    if picture_url == nil
        return "NO URL"
    end
    
    user_picture = Picture.new
    user_picture.url = picture_url
    user_picture.user_googleuniqueid = @user_info['sub']
    
    if user_picture.save
        puts "SAVED"
    else
        puts "NOT SAVE"
    end
    
    redirect "/user"
end

get "/rateperson" do
    "RATE RANDOM"
end

post "/votepicture/:pictureid" do
    @user_info = get_user_info()
    
    if @user_info == nil
        redirect '/login'
    end
    
    picture_id = params[:pictureid]
    
    picture_vote = Picturevotes.new
    
    picture_vote.user_googleuniqueid = @user_info['sub']
    picture_vote.picture_id = picture_id
    
    if picture_vote.save
        print "SAVED"
    else
        print "NOT SAVED"
    end
    
    "RATING RECEIVED"
end





