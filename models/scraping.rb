class Scraping < ActiveRecord::Base
  belongs_to :search

  validates :title, :price, presence: true

  enum :store, [ :amazon, :magazine_luiza, :americanas, :submarino ]
end