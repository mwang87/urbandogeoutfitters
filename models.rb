require 'dm-migrations'
require 'dm-serializer'
require 'dm-constraints'


puts ENV["RACK_ENV"]
configure :development do
    DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/data.db")
    set :current_url, 'http://localhost:9292/'
end
configure :production do
    require 'newrelic_rpm'
    DataMapper.setup(:default, ENV['DATABASE_URL'] )
    set :current_url, 'http://urbandogeoutfitters.herokuapp.com/'
end

DataMapper::Property::String.length(1024)
    
class Picture
    include DataMapper::Resource
    property :id,               Serial
    property :url,              String
    property :title,              String
    property :description,      Text
    
    has n, :picturevotes
    
    belongs_to :user
end

class Picturevote
    include DataMapper::Resource
    property :id,               Serial
    property :updown,           Integer #0 for down 1 for up
    
    belongs_to :picture
    belongs_to :user
end

class Comparisoninstance
    include DataMapper::Resource
    property :id,               Serial
    property :instancehash,     String
    property :usedup,           Integer

end


class User
    include DataMapper::Resource
    property :googleuniqueid,   String, :key => true
    property :googleemail,      String
    property :useralias,        String
    
    has n, :pictures
    has n, :picturevotes
end


DataMapper.finalize
Picture.auto_migrate! unless Picture.storage_exists?
Picturevote.auto_migrate! unless Picturevote.storage_exists?
User.auto_migrate! unless User.storage_exists?
Comparisoninstance.auto_migrate! unless Comparisoninstance.storage_exists?
DataMapper.auto_upgrade!

