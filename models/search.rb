class Search < ActiveRecord::Base

  scope :by_created,->{ order("created_at DESC") }
  has_many :scrapings, dependent: :destroy
  validates :term, presence: true
end