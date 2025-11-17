require 'sinatra'
require 'net/http'
require "sinatra/activerecord"
require 'chartkick'
require 'groupdate'
require './scrapers/amazon_scraper'
# require './scrapers/magazine_luiza_scraper'
# require './scrapers/americanas_scraper'
# require './scrapers/submarino_scraper'

current_dir = Dir.pwd
Dir["#{current_dir}/models/*.rb"].each { |file| require file }

set :root, File.join(File.dirname(__FILE__), '..')
set :views, Proc.new { File.join(root, "views") } 

class BooksApp < Sinatra::Base
  register Sinatra::ActiveRecordExtension

  get '/' do
    erb :index, layout: :layout
  end

  post '/search' do
    term = params[:q]

    @search = Search.create(term: term)

    @amazon_scraper  = AmazonScraper.new(term)
    
    @search.scrapings.create(store: :amazon, link: @amazon_scraper.link, title: @amazon_scraper.title, price: @amazon_scraper.price)

    response.headers['Content-Type'] = 'text/vnd.turbo-stream.html'
    erb :results, layout: false
  end

  get '/searches' do
    @searches = Search.all

    erb :searches, layout: :layout
  end
end
