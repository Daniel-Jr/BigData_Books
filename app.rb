require 'sinatra'
require 'net/http'
require "sinatra/activerecord"

current_dir = Dir.pwd
Dir["#{current_dir}/models/*.rb"].each { |file| require file }

set :root, File.join(File.dirname(__FILE__), '..')
set :views, Proc.new { File.join(root, "views") } 

class BooksApp < Sinatra::Base
  register Sinatra::ActiveRecordExtension

  get '/' do
    erb :index
  end
end
