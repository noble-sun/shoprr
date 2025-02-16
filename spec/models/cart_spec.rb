require 'rails_helper'

RSpec.describe Cart, type: :model do
  describe 'enum' do
    it 'defines values for status attribute' do
      expect(described_class.statuses.keys).to contain_exactly('active', 'ordered')
    end
  end

  describe '#update_cart_item' do
    context 'when item is not already in the cart' do
      it 'create new cart_item for product' do
        cart = create(:cart)
        product = create(:product)

        cart.update_cart_item(product, 2)

        expect(cart.cart_items.count).to eq(1)
      end
    end

    context 'when there is a different product in the cart' do
      it 'create new cart_item for product' do
        cart = create(:cart)
        cart_item = create(:cart_item, cart: cart)
        second_product = create(:product, name: 'Second item on cart')

        cart.update_cart_item(second_product, 2)

        expect(cart.cart_items.count).to eq(2)
      end
    end

    context 'when there is an item with the same product in the cart' do
      context 'update existing cart_item' do
        it 'when increasing product quantity' do
          cart = create(:cart)
          product = create(:product)
          cart_item = create(:cart_item, cart: cart, product: product, quantity: 3)

          cart.update_cart_item(product, 4)

          expect(cart.cart_items.count).to eq(1)
          expect(cart_item.reload.quantity).to eq(4)
        end

        it 'when decreasing product quantity' do
          cart = create(:cart)
          product = create(:product)
          cart_item = create(:cart_item, cart: cart, product: product, quantity: 3)

          cart.update_cart_item(product, 1)

          expect(cart.cart_items.count).to eq(1)
          expect(cart_item.reload.quantity).to eq(1)
        end
      end
    end

    context 'when quantity is equal to zero' do
      it 'remove cart_item from cart' do
        cart = create(:cart)
        product = create(:product)
        cart_item = create(:cart_item, cart: cart, product: product)

        cart.update_cart_item(product, 0)

        expect(cart.cart_items.count).to be_zero
      end
    end
  end
end
