def isUserLoggedIn()
	@user_info = get_user_info()
    
    if @user_info == nil
        redirect '/login'
    end

    return @user_info
end