# frozen_string_literal: true

require 'httparty'
require 'nokogiri'
require 'cgi'

class AmazonScraper
  AMAZON_BR_URL = 'https://www.amazon.com.br'
  attr_accessor :search_url, :link, :title, :price

  def initialize(search_term)
    @search_term = search_term
    @search_url = build_search_url
    scrape
  end

    # Main method to run the scraper
  def scrape
    puts "Searching for: \e[33m#{@search_term}\e[0m on Amazon Brazil..."
    search_page = fetch_page(@search_url)

    if search_page
      book_link = find_first_book_link(search_page)
      if book_link
        puts "Found book link: \e[34m#{book_link}\e[0m"
        @link = "#{AMAZON_BR_URL}#{book_link}"
        puts "Full product link: \e[34m#{@link}\e[0m"
        product_page = fetch_page(@link)
        if product_page
          @title, @price = extract_details(product_page)
        else
          puts "\e[31mError: Could not fetch product page.\e[0m"
        end
      else
        puts "\e[31mError: Could not find any book results for '#{@search_term}'.\e[0m"
      end
    else
      puts "\e[31mError: Could not fetch search results page.\e[0m"
    end
  end

  private

  # Helper to fetch the HTML content of a URL
  def fetch_page(url)
    response = HTTParty.get(url, headers: { 'User-Agent' => 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/118.0' })
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

  # Builds the Amazon search URL
  def build_search_url
    query = CGI.escape(@search_term)
    "#{AMAZON_BR_URL}/s?k=#{query}&i=stripbooks"
  end

  # Finds the link to the first book product page
  def find_first_book_link(search_page)
    # Selector for the first search result link. Trying a more general selector.
    search_page.at_css('div[data-component-type="s-search-result"] a.a-link-normal')&.attr('href')
  end

  # Extracts the book title and price from the product page
  def extract_details(product_page)
    # Selector for the book title
    title_element = product_page.at_css('#productTitle')
    title = title_element ? title_element.text.strip : 'Title not found'

    price_element = product_page.at_css('.a-price-whole')&.text.strip + product_page.at_css('.a-price-fraction')&.text.strip rescue nil # Attempt to combine whole and fraction

    puts  "Raw price element: \e[34m#{price_element}\e[0m"
    
    price = price_element ? price_element.sub(",", ".").to_f : nil

    puts "Extracted Title: \e[32m#{title}\e[0m"
    puts "Extracted Price: \e[32m#{price}\e[0m"
    
    [title, price]
  end
end