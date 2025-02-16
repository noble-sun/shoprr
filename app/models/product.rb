class Product < ApplicationRecord
  has_many_attached :images
  has_many :cart_items
  has_many :carts, through: :orderables

  validates_presence_of :name, :description, :quantity, :price
  validates :quantity, :price, numericality: { greater_than_or_equal_to: 0 }
end
