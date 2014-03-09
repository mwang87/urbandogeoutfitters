def get_random_comparison_pictures(user_id)
    
    all_pictures = Picture.all
    
    all_user_votes = Picturevote.all(:user_googleuniqueid => user_id)
    
    all_user_votes.each{ |vote| puts vote.picture_id }
    
    picture_size = all_pictures.length
    
    random1 = rand(picture_size)
    random2 = rand(picture_size)
    
    return all_pictures[random1], all_pictures[random2]
end