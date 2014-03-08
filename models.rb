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
    set :current_url, 'http://channelflipper.herokuapp.com/'
end
    
class Picture
    include DataMapper::Resource
    property :id,               Serial
    property :url,              String
    
    has n, :comparisons, :child_key => [ :source_id ]
    has n, :ratings, self, :through => :comparisons, :via => :target
    
    belongs_to :user
end

class Comparison
    include DataMapper::Resource
    property :id,               Serial
    property :comparisonvalue,  String
    
    belongs_to :source, 'Picture'
    belongs_to :target, 'Picture'
    
    belongs_to :user
end


class User
    include DataMapper::Resource
    
    property :googleuniqueid,   String, :key => true
    property :googleemail,      String
    property :useralias,        String
    
    has n, :pictures
    has n, :comparisons
end


DataMapper.finalize
Picture.auto_migrate! unless Picture.storage_exists?
Comparison.auto_migrate! unless Comparison.storage_exists?
User.auto_migrate! unless User.storage_exists?
DataMapper.auto_upgrade!

