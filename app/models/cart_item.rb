class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product

  validates :quantity, :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validate :stock_availabillity

  private

  def stock_availabillity
    if product && (quantity > product.quantity)
      errors.add(:quantity, "Not enough stock available of this product")
    end
  end
end
