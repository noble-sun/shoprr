class Product < ApplicationRecord
  has_many_attached :images

  validates_presence_of :name, :description, :quantity, :price
  validates :quantity, :price, numericality: { greater_than_or_equal_to: 0 }
end
