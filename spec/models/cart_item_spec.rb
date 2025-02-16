require 'rails_helper'

RSpec.describe CartItem, type: :model do
  context 'validate if product is in stock' do
    it 'should be valid if there is enough stock for product' do
      cart = create(:cart)
      product = create(:product, quantity: 2)

      item = described_class.new(cart: cart, product: product, quantity: 2)

      expect(item.valid?).to be_truthy
    end

    it 'showd be invalid if there is not enough stock for the product'do
      cart = create(:cart)
      product = create(:product, quantity: 2)

      item = described_class.new(cart: cart, product: product, quantity: 3)

      item.valid?
      expect(item.errors.full_messages.to_sentence).to eq('Quantity insufficient for this product')
    end
  end

  context 'set cart item price' do
    it 'when price is not informed' do
      cart = create(:cart)
      product = create(:product, quantity: 2, price: 10.0)

      item = described_class.create(cart: cart, product: product, quantity: 2)

      expect(item.reload.price).to eq(20.0)
    end

    it 'use informed price instead of the default calculation' do
      cart = create(:cart)
      product = create(:product, quantity: 2, price: 10.0)

      item = described_class.create(cart: cart, product: product, quantity: 2, price: 14.99)

      expect(item.reload.price).to eq(14.99)

    end

    context 'when updating an existing cart item' do
      it 'update price if it is not informed' do
        cart = create(:cart)
        product = create(:product, quantity: 2, price: 10.0)
        cart_item = create(:cart_item, cart: cart, product: product, price: 20.0)

        cart_item.update!(quantity: 1)

        expect(cart_item.reload.price).to eq(10.0)
      end

      it 'use price if explicitly informed' do
        cart = create(:cart)
        product = create(:product, quantity: 2, price: 10.0)
        cart_item = create(:cart_item, cart: cart, product: product, price: 20.0)

        cart_item.update!(quantity: 1, price: 4.99)

        expect(cart_item.reload.price).to eq(4.99)
      end
    end
  end
end
