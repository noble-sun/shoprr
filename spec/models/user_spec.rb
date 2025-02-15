require 'rails_helper'

RSpec.describe User, type: :model do
  describe '.authenticate_by' do
    it 'returns user if email_address and password are valid' do
      user = create(:user, email_address: 'user@email.com', password: 'pass@123')

      authenticated_user = User.authenticate_by({ login: 'user@email.com', password: 'pass@123' })

      expect(authenticated_user).to eq(user)
    end

    it 'returns user if cpf and password are valid' do
      user = create(:user, cpf: '12312312312', password: 'pass@123')

      authenticated_user = User.authenticate_by({ login: '12312312312', password: 'pass@123' })

      expect(authenticated_user).to eq(user)
    end

    context 'returns nil' do
      it 'when password is incorrect' do
        user = create(:user, cpf: '12312312312', password: 'pass@123')

        authenticated_user = User.authenticate_by({
          login: '12312312312', password: 'incorrect-password'
        })

        expect(authenticated_user).to be_falsy
      end

      it 'when email or cpf is incorrect' do
        user = create(:user, cpf: '12312312312', password: 'pass@123')

        authenticated_user = User.authenticate_by({
          login: 'invalid-login', password: 'pass@123'
        })

        expect(authenticated_user).to be_nil
      end
    end
  end
end
