class Product < ApplicationRecord
  has_many_attached :images

  validates_presence_of :name, :description, :quantity
end
