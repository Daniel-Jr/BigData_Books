# frozen_string_literal: true

require 'httparty'
require 'nokogiri'
require 'cgi'

# A simple web scraper for Mercado Livre book prices.
class MercadoLivreScraper
  MERCADOLIVRE_URL = 'https://lista.mercadolivre.com.br'
  attr_accessor :link, :title, :price

  def initialize(book_title)
    @book_title = book_title
    @search_url = build_search_url
    scrape
  end

  # Main method to run the scraper
  def scrape
    puts "Searching for: \e[33m#{@book_title}\e[0m on Mercado Livre..."
    search_page = fetch_page(@search_url)

    if search_page
      # Check for login/block page content
      if search_page.at_css('title').text.include?('Mercado Livre') && search_page.at_css('a:contains("Já tenho conta")')
        puts "\e[31mError: Mercado Livre is blocking the request (Login/Verification page).\e[0m"
        puts "A simple scraper cannot bypass this. Please see the README for alternatives."
        return
      end

      puts "Fetched search page from: \e[34m#{@search_url}\e[0m"

      book_link = find_first_book_link(search_page)
      puts "Found book link: \e[34m#{book_link}\e[0m"
      if book_link
        @link = book_link # Mercado Livre links are often absolute URLs
        product_page = fetch_page(@link)
        if product_page
          @title, @price = extract_details(product_page)
        else
          puts "\e[31mError: Could not fetch product page.\e[0m"
        end
      else
        puts "\e[31mError: Could not find any book results for '#{@book_title}'.\e[0m"
      end
    else
      puts "\e[31mError: Could not fetch search results page.\e[0m"
    end
  end

  private

  # Helper to fetch the HTML content of a URL
  def fetch_page(url)
    # Use a standard browser User-Agent
    headers = { 'User-Agent' => 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36' }
    
    response = HTTParty.get(url, headers: headers)
    
    if response.code == 200
      Nokogiri::HTML(response.body)
    else
      puts "\e[31mHTTP Error: #{response.code} for URL: #{url}\e[0m"
      nil
    end
  rescue StandardError => e
    puts "\e[31mNetwork Error: #{e.message}\e[0m"
    nil
  end

  # Builds the Mercado Livre search URL
  def build_search_url
    query = CGI.escape(@book_title)
    # Mercado Livre search URL structure: /search/query
    "#{MERCADOLIVRE_URL}/#{query}"
  end

  # Finds the link to the first book product page
  def find_first_book_link(search_page)
    # Mercado Livre product links are often found within a div with a specific class.
    # The link itself often contains the product ID.
    search_page.at_css('a.poly-component__title')&.attr('href')
  end

  # Extracts the book title and price from the product page
  def extract_details(product_page)
    # Selector for the book title.
    title_element = product_page.at_css('h1.ui-pdp-title')
    title = title_element ? title_element.text.strip : 'Title not found'

    # Selector for the price.
    # Mercado Livre uses a specific structure for the price.
    price_whole = product_page.at_css('span.andes-money-amount__fraction')&.text
    price_cents = product_page.at_css('span.andes-money-amount__cents')&.text
    
    if price_whole
      price = "#{price_whole}"
      price += ",#{price_cents}" if price_cents
    else
      price = 'Price not found'
    end

    converted_price = price ? price.sub(",", ".").to_f : nil

    
    puts  "Extracted Title: \e[32m#{title}\e[0m"
    puts  "Extracted Price: \e[32m#{converted_price}\e[0m"
    [title, converted_price]
  end
end