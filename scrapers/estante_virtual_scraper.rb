# frozen_string_literal: true

require 'httparty'
require 'nokogiri'
require 'cgi'

# A simple web scraper for Estante Virtual book prices.
class EstanteVirtualScraper
  ESTANTEVIRTUAL_URL = 'https://www.estantevirtual.com.br'
  attr_accessor :link, :title, :price

  def initialize(book_title)
    @book_title = book_title
    @search_url = build_search_url
    scrape
  end

  # Main method to run the scraper
  def scrape
    puts "Searching for: \e[33m#{@book_title}\e[0m on Estante Virtual..."
    search_page = fetch_page(@search_url)

    if search_page
      book_link = find_first_book_link(search_page)
      puts "Book link found: \e[34m#{book_link}\e[0m"
      if book_link
        @link = "#{ESTANTEVIRTUAL_URL}#{book_link}"
        puts "Fetching product page: \e[34m#{@link}\e[0m"
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

  # Builds the Estante Virtual search URL
  def build_search_url
    query = CGI.escape(@book_title)
    # Estante Virtual search URL structure: /busca?q=query
    "#{ESTANTEVIRTUAL_URL}/busca?q=#{query}"
  end

  # Finds the link to the first book product page
  def find_first_book_link(search_page)
    # Estante Virtual product links are often found within a div with a specific class.
    # The link itself often contains the product ID.
    # The search results page shows a list of books, each with a link to the product page.
    # The link is usually wrapped around the book title.
    search_page.at_css('a.link-livro')&.attr('href') ||
    search_page.at_css('a.link-livro-titulo')&.attr('href') ||
    search_page.at_css('a[href*="/livro/"]')&.attr('href')
  end

  # Extracts the book title and price from the product page
  def extract_details(product_page)
    # Selector for the book title.
    title_element = product_page.at_css('h1.livro-titulo') ||
                    product_page.at_css('h1')
    title = title_element ? title_element.text.strip : 'Title not found'

    # Selector for the price.
    # Estante Virtual shows a list of offers, we want the lowest price.
    # The price is found in a strong tag within the product offer section.
    price_element = product_page.at_css("span.book-copy__price__sale-price")
    
    raw_price = price_element ? price_element.text.gsub("R$", "").strip : 'Price not found'

    price = raw_price ? raw_price.sub(",", ".").to_f : nil

    puts "Extracted Title: \e[32m#{title}\e[0m"
    puts "Extracted Price: \e[32m#{price}\e[0m"

    [title, price]
  end
end