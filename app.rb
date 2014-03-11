require 'sinatra'
require 'data_mapper'
require './models'
require './userauth'
require './usercontroller'
require './ratinghelper'
require './loginhelper'

user_configure();

enable :sessions
set :session_secret, 'super secret2'


get "/" do
    if session[:googleemail] != nil
        redirect '/user'
    end

    haml :index  
end


get "/vote" do
    @user_info = isUserLoggedIn()

    @comparison_picture1, @comparison_picture2 = get_random_comparison_pictures(@user_info['sub'])
    
    
    @comparison_instance = create_comparison_instance()
    
    haml :vote
end


post "/upload" do  
    @user_info = isUserLoggedIn()

    picture_url = params[:pictureURL]
    
    if picture_url == nil
        return "NO URL"
    end
    
    user_picture = Picture.new
    user_picture.url = picture_url
    user_picture.user_googleuniqueid = @user_info['sub']
    
    puts user_picture.url
    puts user_picture.user_googleuniqueid
    puts user_picture.id
    
    if user_picture.save
        puts "SAVED"
    else
        puts "NOT SAVE"
    end
    
    redirect "/user"
end


post "/votepicture" do  
    @user_info = isUserLoggedIn()

    instance_hash = params[:instancehash]
    instance_object = Comparisoninstance.first(:instancehash => instance_hash)
    
    if instance_object == nil
        return "NOT RATED, NO INSTANCE"
    end
    if instance_object.usedup == 1
        return "NOT RATED, INSTANCE USED"
    end
    instance_object.usedup = 1
    if instance_object.save
        print "UPDATED INSTANCE"
    else
        print "FAILED UPDATE INSTANCE"
    end
    
    
    
    upvote_id = params[:upvote]
    downvote_id = params[:downvote]
    
    upvote_vote = Picturevote.new
    upvote_vote.user_googleuniqueid = @user_info['sub']
    upvote_vote.picture_id = upvote_id 
    upvote_vote.updown = 1
    
    
    if upvote_vote.save
       print "SAVED"
    else
       print "NOT SAVED"
    end
    
    downvote_vote = Picturevote.new
    downvote_vote.user_googleuniqueid = @user_info['sub']
    downvote_vote.picture_id = downvote_id 
    downvote_vote.updown = 0

    
    if downvote_vote.save
       print "SAVED"
    else
       print "NOT SAVED"
    end
    

    "RATING RECEIVED"
end






