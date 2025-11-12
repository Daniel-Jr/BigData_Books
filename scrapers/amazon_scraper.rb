# frozen_string_literal: true

require 'httparty'
require 'nokogiri'
require 'cgi'

class AmazonScraper
  AMAZON_BR_URL = 'https://www.amazon.com.br'
  attr_accessor :title, :price

  def initialize(book_title)
    @book_title = book_title
    @search_url = build_search_url
  end

    # Main method to run the scraper
  def scrape
    puts "Searching for: \e[33m#{@book_title}\e[0m on Amazon Brazil..."
    search_page = fetch_page(@search_url)

    if search_page
      if search_page.at_css('form[action="/errors/validateCaptcha"]')
        puts "\e[31mError: Amazon is requesting a CAPTCHA. The scraper is being blocked.\e[0m"
        return
      end

      book_link = find_first_book_link(search_page)
      if book_link
        puts "Found book link: \e[34m#{book_link}\e[0m"
        product_url = "#{AMAZON_BR_URL}#{book_link}"
        product_page = fetch_page(product_url)
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
    sleep(rand(1..5)) # Add a random delay to be polite and avoid rate-limiting
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
    query = CGI.escape(@book_title)
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

    # Selector for the price. Amazon uses different selectors, so we try a few common ones.
    # The main price is often found in the a-price-whole and a-price-fraction span elements.
    price_element = product_page.at_css('#priceblock_ourprice') ||
                    product_page.at_css('#priceblock_dealprice') ||
                    product_page.at_css('.a-price .a-offscreen') ||
                    product_page.at_css('.a-price-whole')&.text.strip + product_page.at_css('.a-price-fraction')&.text.strip rescue nil # Attempt to combine whole and fraction
    
    # If the combined price is nil, try the main price block again
    price_element = product_page.at_css('.a-price .a-offscreen') if price_element.nil?
    
    # Fallback for the main price block on the product page
    price_element = product_page.at_css('#corePriceDisplay_desktop_feature_div .a-offscreen') if price_element.nil?

    price = price_element ? price_element.text.strip : 'Price not found'
    
    [title, price]
  end
end