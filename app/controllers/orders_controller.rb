class OrdersController < ApplicationController
  
  def index
    @orders = Current.user.orders
  end

  def new
    @order = Order.new
    @addresses = Current.user.addresses
  end

  def create
    user = Current.user
    cart = user.active_cart

    @order = Order.new(order_params.merge(user: user, cart: cart))

    ActiveRecord::Base.transaction do
      cart.cart_items.each do |item|
        item.update_product_stock!
      end
      cart.ordered!
      @order.processing!

      redirect_to root_path, notice: "Order is being processed right now!!! =)"
    rescue
      redirect_to cart_path(user.active_cart), alert: "Could not complete order =("
    end
  end

  private

  def order_params
    params.require(:order).permit(:address_id, :cart_id, :user_id)
  end
end
