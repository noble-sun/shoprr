require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'Validations' do
    context 'when valid attributes are provided' do
      it 'is valid' do
        user = build(:user)
        expect(user).to be_valid
      end
    end

    context 'when invalid attributes are provided' do
      context 'cpf' do
        context 'length' do
          it "is invalid with more than 11 digits" do
            user = build(:user, cpf: '790271230201')

            expect(user).to be_invalid
            expect(user.errors[:cpf]).to include('is the wrong length (should be 11 characters)')
          end

          it "is invalid with less than 11 digits" do
            user = build(:user, cpf: '123456789')

            expect(user).to be_invalid
            expect(user.errors[:cpf]).to include('is the wrong length (should be 11 characters)')
          end
        end

        context 'numeric' do
          it 'is invalid with non numeric characters' do
            user = build(:user, cpf: 'invalid1234')

            expect(user).to be_invalid
            expect(user.errors[:cpf]).to include('is not a number')
          end
        end

        context 'verification digit' do
          it 'is invalid when verification digits do not match' do
            user = build(:user, cpf: '79027123099')

            expect(user).to be_invalid
            expect(user.errors[:cpf]).to include('invalid verification digit')
          end
        end
      end
    end
  end

  describe '.authenticate_by' do
    it 'returns user if email_address and password are valid' do
      user = create(:user, email_address: 'user@email.com', password: 'pass@123')

      authenticated_user = User.authenticate_by({ login: 'user@email.com', password: 'pass@123' })

      expect(authenticated_user).to eq(user)
    end

    it 'returns user if cpf and password are valid' do
      user = create(:user, cpf: '79027123020', password: 'pass@123')

      authenticated_user = User.authenticate_by({ login: '79027123020', password: 'pass@123' })

      expect(authenticated_user).to eq(user)
    end

    context 'returns nil' do
      it 'when password is incorrect' do
        user = create(:user, cpf: '79027123020', password: 'pass@123')

        authenticated_user = User.authenticate_by({
          login: '79027123020', password: 'incorrect-password'
        })

        expect(authenticated_user).to be_falsy
      end

      it 'when email or cpf is incorrect' do
        user = create(:user, cpf: '79027123020', password: 'pass@123')

        authenticated_user = User.authenticate_by({
          login: 'invalid-login', password: 'pass@123'
        })

        expect(authenticated_user).to be_nil
      end
    end
  end
end
