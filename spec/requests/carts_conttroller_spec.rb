require 'rails_helper'

RSpec.describe CartsController, type: :request do
  describe 'POST /add' do
    context 'add product to cart' do
      context 'when there is available stock' do
        it 'successfullly' do
          user = create(:user)
          cart = create(:cart, user: user)
          product = create(:product)

          post session_url, params: { login: user.email_address, password: user.password }

          post '/carts/add', params: { id: product.id, quantity: 2 }

          expect(cart.cart_items.count).to eq(1)
        end
      end

      context 'when there is not enough stock' do
        it 'does not add product to cart' do
          user = create(:user)
          cart = create(:cart, user: user)
          product = create(:product, quantity: 1)

          post session_url, params: { login: user.email_address, password: user.password }

          post '/carts/add', params: { id: product.id, quantity: 5 }

          expect(cart.cart_items.count).to be_zero
        end
      end
    end

    context 'update product quantity' do
      context 'when there is available stock' do
        it 'successfullly' do
          user = create(:user)
          product = create(:product, quantity: 4)
          cart = create(:cart, user: user)
          cart_item = create(:cart_item, cart: cart, product: product, quantity: 2)

          post session_url, params: { login: user.email_address, password: user.password }

          post '/carts/add', params: { id: product.id, quantity: 3 }

          expect(cart.cart_items.count).to eq(1)
          expect(cart_item.reload.quantity).to eq(3)
        end
      end

      context 'when there is not enough stock' do
        it 'does not add product to cart' do
          user = create(:user)
          product = create(:product, quantity: 4)
          cart = create(:cart, user: user)
          cart_item = create(:cart_item, cart: cart, product: product, quantity: 2)

          post session_url, params: { login: user.email_address, password: user.password }

          post '/carts/add', params: { id: product.id, quantity: 5 }

          expect(cart.cart_items.count).to eq(1)
          expect(cart_item.reload.quantity).to eq(2)
        end
      end
    end
  end
end
