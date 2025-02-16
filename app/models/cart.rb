class Cart < ApplicationRecord
  belongs_to :user
  has_many :cart_items
  has_many :products, through: :cart_items

  validates_presence_of :status

  enum :status, { active: 'active', ordered: 'ordered' }

  def total
    cart_items.pluck(:price).sum
  end

  def update_cart_item(product, quantity)
    cart_item = cart_items.find_by(product:)

    if cart_item && quantity > 0
      cart_item.update!(quantity:, price: product.price * quantity)
    elsif quantity <= 0
      cart_item.destroy!
    else
      cart_items.create!(product:, quantity:, price: product.price * quantity)
    end
  end
end
