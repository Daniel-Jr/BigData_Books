class Scraping < ActiveRecord::Base
  belongs_to :search

  validates :title, :price, presence: true

  enum :store, [ :amazon, :mercado_livre, :americanas, :submarino ]
end