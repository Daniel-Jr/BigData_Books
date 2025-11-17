require 'sinatra'
require 'net/http'
require "sinatra/activerecord"
require 'chartkick'
require 'groupdate'
require './scrapers/amazon_scraper'
require './scrapers/mercado_livre_scraper'
require './scrapers/estante_virtual_scraper'
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
    @mercado_livre_scraper = MercadoLivreScraper.new(term)
    @estante_virtual_scraper = EstanteVirtualScraper.new(term)
    
    @search.scrapings.create(store: :amazon, link: @amazon_scraper.link, title: @amazon_scraper.title, price: @amazon_scraper.price)
    @search.scrapings.create(store: :mercado_livre, link: @mercado_livre_scraper.link, title: @mercado_livre_scraper.title, price: @mercado_livre_scraper.price)
    @search.scrapings.create(store: :estante_virtual, link: @estante_virtual_scraper.link, title: @estante_virtual_scraper.title, price: @estante_virtual_scraper.price)

    response.headers['Content-Type'] = 'text/vnd.turbo-stream.html'
    erb :results, layout: false
  end

  get '/searches' do
    @searches = Search.by_created

    erb :searches, layout: :layout
  end
end
