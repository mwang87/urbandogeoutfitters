#Update
post '/user' do
    @user_info = get_user_info()
    
    if @user_info == nil
        redirect '/login'
    end
    
    puts params[:useralias]
    update_user(@user_info['sub'], params[:useralias])
    
    redirect '/user'
end
   
#GET View User
get '/user' do
    @user_info = get_user_info()
    if @user_info == nil
        redirect '/login'
    end
    puts @user_info
    erb :user
end


#Creates and returns user
def create_user(user_id, user_email)
    
    puts user_id
    puts user_email
    new_user = User.first_or_create( {:googleuniqueid => user_id},{
                                                                :googleuniqueid => user_id,
                                                                :googleemail => user_email,
                                                                :useralias => user_email,
                                                                });
    new_user.save
    return new_user
end
        
def get_user_alias(user_id)
    existing_user = User.first( {:googleuniqueid => user_id} )
    if existing_user != nil
        if existing_user.useralias == nil
            existing_user.useralias = existing_user.googleemail
            existing_user.save
        end
        return existing_user.useralias
    end
    return nil
end


def update_user(user_id, user_alias)
    existing_user = User.first( {:googleuniqueid => user_id} )
    if existing_user != nil
        existing_user.useralias = user_alias
        session[:useralias] = user_alias
        if existing_user.save
            puts "SAVE SUCCESS"
        else
            puts "NO SAVE"
        end
            
    end
end