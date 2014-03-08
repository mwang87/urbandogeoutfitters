require 'dm-migrations'
require 'dm-serializer'
require 'dm-constraints'

puts ENV["RACK_ENV"]
if ENV["RACK_ENV"] == "development"
    DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/data.db")
end
if ENV["RACK_ENV"] == "production"
    DataMapper.setup(:default, ENV['DATABASE_URL'] )
end
    
#DataMapper.setup(:default, ENV['HEROKU_POSTGRESQL_VIOLET_URL'] || 'postgres://vrsuhllnluwzby:fn7JWeN9MvlJwnQC2IKO0HOpwk@ec2-54-225-101-4.compute-1.amazonaws.com:5432/dbfgk3co86vbss' )

class Picture
    include DataMapper::Resource
    property :id,               Serial
    property :url,              String
    
    has n, :comparisons, :child_key => [ :source_id ]
    has n, :friends, self, :through => :comparisons, :via => :target
    
    belongs_to :fashionableuser
end

class Comparison
    include DataMapper::Resource
    property :id,               Serial
    property :comparisonvalue,  String
    
    belongs_to :source, 'Picture', :key => true
    belongs_to :target, 'Picture', :key => true
    
    belongs_to :fashionableuser
end


class Fashionableuser
    include DataMapper::Resource
    
    property :googleuniqueid,   String, :key => true
    property :googleemail,      String
    property :useralias,        String
    
    has n, :picture
    has n, :comparison
end


DataMapper.finalize
Picture.auto_migrate! unless Picture.storage_exists?
Comparison.auto_migrate! unless Comparison.storage_exists?
Fashionableuser.auto_migrate! unless Fashionableuser.storage_exists?
DataMapper.auto_upgrade!

