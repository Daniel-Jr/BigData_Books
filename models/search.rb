class Search < ActiveRecord::Base
  has_many :scrapings, dependent: :destroy
  validates :term, presence: true
end