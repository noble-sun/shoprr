class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product

  validates :quantity, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validate :stock_availabillity

  before_save :update_price, unless: -> { will_save_change_to_price? }

  def update_product_stock!
    product.update!(quantity: product.quantity - quantity)
  end

  private

  def stock_availabillity
    if product && (quantity > product.quantity)
      errors.add(:quantity, "insufficient for this product")
    end
  end

  def update_price
    self.price = quantity * product.price
  end
end
