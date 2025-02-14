require 'rails_helper'

RSpec.describe Product, type: :model do
  let(:product) { build(:product) }

  context 'should be valid' do
    it 'when all attributes are present' do
      expect(product).to be_valid
    end

    it 'when just the image is not present' do
      product.images = []
      expect(product).to be_valid
    end

    it 'when more than one image is attached' do
      product_with_images = create(:product, :with_multiple_images)
      expect(product_with_images).to be_valid
    end
  end

  context 'should not be valid' do
    it 'when name is not present' do
      product.name = nil
      expect(product).not_to be_valid
    end

    it 'when descripttion is not present' do
      product.description = nil
      expect(product).not_to be_valid
    end

    context 'when quantity' do
      it 'is not present' do
        product.quantity = nil
        expect(product).not_to be_valid
      end
     
      it 'is a negative number' do
        product.quantity = -1
        expect(product).not_to be_valid
      end
    end

    context 'when price' do
      it 'is not present' do
        product.price = nil
        expect(product).not_to be_valid
      end

      it 'is a negative number' do
        product.price = -1.5
        expect(product).not_to be_valid
      end
    end
  end
end
