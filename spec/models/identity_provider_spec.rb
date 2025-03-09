require 'rails_helper'

RSpec.describe IdentityProvider, type: :model do
  describe 'enum' do
    it 'defines values for name attribute' do
      expect(described_class.names.keys).to contain_exactly('google')
    end
  end
end
