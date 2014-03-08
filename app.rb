require 'sinatra'
require 'data_mapper'
require './models'
require './userauth'
require './usercontroller'

user_configure();

get "/" do
    "MING"
end