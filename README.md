# BigData Books - Search & Price Tracking Application

A web application built with Sinatra that scrapes book prices from multiple online retailers and displays them in an interactive dashboard.

## 📋 Overview

BigData Books is a data scraping application that allows you to search for books and compare prices across different online stores (Amazon, Americanas, Magazine Luiza, Submarino). Results are displayed with interactive charts powered by Chart.js.

## 🛠️ Tech Stack

- **Backend**: Ruby with Sinatra framework
- **Database**: SQLite3
- **Scraping**: Nokogiri & HTTParty
- **Charts**: Chartkick with Chart.js
- **Frontend**: ERB templates with Turbo streams
- **Styling**: Simple.css

## 📦 Installation

### Prerequisites

- Ruby 3.4.4
- Bundler

### Setup Steps

1. **Clone the repository**
```bash
git clone <repository-url>
cd bigdata_books
```

2. **Install dependencies**
```bash
bundle install
```

3. **Set up the database**
```bash
rake db:create
rake db:migrate
```

4. **Start the application**
```bash
./bin/dev
```

The application will be available at `http://localhost:9292`

## 🚀 Usage

### Searching for Books

1. Navigate to the **Home** page
2. Enter a book name in the search box
3. Click **"Buscar"** (Search) button
4. View results with:
   - Book title and store name
   - Price in Brazilian Reais (R$)
   - Direct link to the product on the store
   - Price comparison chart

### Viewing Search History

1. Click on **"Buscas"** (Searches) in the navigation menu
2. View all previous searches and their results
3. See price trends and comparisons over time

## 📁 Project Structure

```
bigdata_books/
├── app.rb                          # Main application file
├── Gemfile                         # Ruby dependencies
├── Rakefile                        # Database tasks
├── bin/
│   └── dev                         # Development server starter
├── app/
│   └── config.ru                   # Rack configuration
├── config/
│   └── database.yml                # Database configuration
├── db/
│   ├── schema.rb                   # Database schema
│   └── migrate/                    # Migration files
├── models/
│   ├── scraping.rb                 # Scraping model
│   └── search.rb                   # Search model
├── scrapers/                       # Web scraper implementations
│   ├── amazon_scraper.rb
│   ├── americanas_scraper.rb
│   ├── magazine_luiza_scraper.rb
│   └── submarino_scraper.rb
├── views/                          # ERB templates
│   ├── layout.erb                  # Main layout
│   ├── index.erb                   # Home page with search box
│   ├── results.erb                 # Search results view
│   └── searches.erb                # Search history view
└── public/                         # Static assets
    ├── chartkick.js
    ├── chart.umd.js
    └── chartjs-adapter-date-fns.bundle.js
```

## 🔍 Key Features

### Centralized Search Box
- Located on the home page for easy access
- Real-time search with Turbo streams
- Clean, intuitive interface

### Price Comparison
- Aggregates prices from multiple retailers
- Visual price comparison charts
- Store information and direct links

### Search History
- View all previous searches
- Track price changes over time
- Access historical data

## 🗄️ Database Models

### Search
- `id`: Unique identifier
- `term`: Search query
- `created_at`: Timestamp
- Relationship: has_many scrapings

### Scraping
- `id`: Unique identifier
- `search_id`: Foreign key to Search
- `store`: Retailer name (Amazon, Americanas, etc.)
- `title`: Book title
- `price`: Current price in R$
- `link`: Direct product URL
- `created_at`: Timestamp

## 🔧 Configuration

### Database Setup
Update `config/database.yml` for different environments

### Adding New Scrapers
1. Create a new scraper file in `scrapers` directory
2. Implement the scraper class with `title`, `price`, and `link` methods
3. Register it in `app.rb`

## 📊 Charts

The application uses **Chartkick** with **Chart.js** for visualizations:
- Column charts for price comparisons
- Date formatting with date-fns adapter
- Responsive design for all screen sizes

## 🌐 Supported Stores

Currently implemented:
- ✅ Amazon
- 📋 Americanas (commented out)
- 📋 Magazine Luiza (commented out)
- 📋 Submarino (commented out)

Uncomment scrapers in `app.rb` to activate additional stores.

## 📝 API Routes

| Method | Route | Description |
|--------|-------|-------------|
| GET | `/` | Home page with search box |
| POST | `/search` | Submit book search |
| GET | `/searches` | View all searches |
