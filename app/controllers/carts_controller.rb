class CartsController < ApplicationController
  before_action :set_cart

  def show; end

  def add
    product = Product.find_by(id: params[:id])
    quantity = params[:quantity].to_i
    @cart.update_cart_item(product, quantity)
  end

  def remove
    CartItem.find_by(id: params[:id]).destroy
  end

  private

  def set_cart
    @cart = Current.user.active_cart
  end
end
