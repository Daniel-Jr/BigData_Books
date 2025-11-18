# frozen_string_literal: true

require 'httparty'
require 'nokogiri'
require 'cgi'

class TravessaScraper
  TRAVESSA_URL = 'https://www.travessa.com.br'
  attr_accessor :search_url, :link, :title, :price

  def initialize(search_term)
    @search_term = search_term
    @search_url = build_search_url
    scrape
  end

  # Main method to run the scraper
  def scrape
    puts "Searching for: \e[33m#{@search_term}\e[0m on Travessa..."
    search_page = fetch_page(@search_url)

    puts "#{@search_url}"

    if search_page
      book_link = find_first_book_link(search_page)
      
      if book_link
        @link = book_link
        puts "Found book link: \e[34m#{@link}\e[0m"
        product_page = fetch_page(@link)
        if product_page
          @title, @price = extract_details(product_page)
        else
          puts "\e[31mError: Could not fetch product page.\e[0m"
        end
      else
        puts "\e[31mError: No book results found.\e[0m"
      end
    else
      puts "\e[31mError: Could not fetch search results page.\e[0m"
    end
  end

  private

  # Fetch HTML page
  def fetch_page(url)
    response = HTTParty.get(url, headers: {
      'User-Agent' => 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36'
    })

    return Nokogiri::HTML(response.body) if response.code == 200

    puts "\e[31mHTTP Error #{response.code} for #{url}\e[0m"
    nil
  rescue => e
    puts "\e[31mNetwork Error: #{e.message}\e[0m"
    nil
  end

  # Build Travessa search URL
  # https://www.travessa.com.br/busca?q=harry+potter
  def build_search_url
    query = CGI.escape(@search_term)
    "#{TRAVESSA_URL}/Busca.aspx?d=1&refinada=s&cta=1&tt=#{query}&o=1"
  end

  # Extract first product link
  def find_first_book_link(search_page)
    # Travessa search result structure:
    search_page.at_css('h4.search-result-item-heading a')['href']
  end

  # Extract product details
  def extract_details(product_page)
    # Title selector:
    # <h1 class="product__name">
    title_element = product_page.at_css('#lblNomArtigo')
    title = title_element ? title_element.text.strip.capitalize : "Title not found"

    # Price selector:
    # <span class="product__price--sale">R$ 49,90</span>
    price_element = product_page.at_css('#litPreco')

    raw_price = price_element ? price_element.text.strip : nil
    puts "Raw price element: \e[34m#{raw_price}\e[0m"

    price = nil
    if raw_price
      price = raw_price.gsub(/R\$\s*/, "").gsub(".", "").gsub(",", ".").to_f
    end

    [title, price]
  end
end