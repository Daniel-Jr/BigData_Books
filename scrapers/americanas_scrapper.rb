# frozen_string_literal: true

require 'httparty'
require 'nokogiri'
require 'cgi'

class AmericanasScrapper
    AMERICANAS_URL = 'https://www.americanas.com.br'

    attr_accessor :title, :price

    def initialize(book_title)
        @book_title = book_title
        @search_url = build_search_url
    end

    def scrape
        puts "Searching for: \e[33m#{@book_title}\e[0m on Americanas..."
        search_page = fetch_page(@search_url)

        if search_page
            book_link = find_first_book_link(search_page)
        if book_link
            puts "Found book link: \e[34m#{book_link}\e[0m"
            product_url = "#{AMERICANAS_URL}#{book_link}"
            product_page = fetch_page(product_url)
            if product_page
                @title, @price = extract_details(product_page)
            else
                puts "\e[31mError: Could not fetch product page.\e[0m"
            end
        else
            puts "\e[31mError: Could not find any product results for '#{@book_title}'.\e[0m"
        end
        else
            puts "\e[31mError: Could not fetch search results page.\e[0m"
        end
    end

    private 

    def fetch_page(url)
        sleep(rand(1..5)) # Add a random delay to be polite and avoid rate-limiting
        response = HTTParty.get(url, headers: { 'User-Agent' => 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/118.0' })
        #response = HTTParty.get(url, headers: { 'User-Agent' => 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)' })

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

    def build_search_url
        query = CGI.escape(@book_title)
        "#{AMERICANAS_URL}/s?q=#{query}"
    end

    def find_first_book_link(search_page)
        search_page.at_css('a.product-link')&.attr('href')
    end

    def extract_details(product_page)
        # Título
        title_element = product_page.at_css('h1.product-title__title')
        title = title_element ? title_element.text.strip : 'Title not found'

        # Preço
        price_element = product_page.at_css('span.price__SalesPrice') || product_page.at_css('span.price-sales')
        price = price_element ? price_element.text.strip : 'Price not found'

        [title, price]
    end 
end
