require 'rails_helper'

RSpec.describe "Registrations", type: :request do
  describe "POST /create" do
    context 'create a new user' do
      it 'successfully' do
        params = {
          user: {
            name: 'Maria',
            surname: 'Li',
            date_of_birth: '31/12/1999',
            phone: '11123456789',
            email_address: 'valid@email.com',
            cpf: '79027123020',
            password: 'Pass@123'
          }
        }

        expect {
          post '/registrations', params: params
        }.to change(User, :count).by(1)

        user = User.find_by(email_address: params[:user][:email_address])
        expect(user.cpf).to eq('79027123020')
        expect(user.password_digest).to be_present
      end
    end

    context 'fail to create user' do
      it 'when email address already exist' do
        email = 'valid@email.com'
        create(:user, email_address: email)

        params = {
          user: {
            name: email,
            surname: 'Li',
            date_of_birth: '31/12/1999',
            phone: '11123456789',
            email_address: 'valid@email.com',
            cpf: '79027123020',
            password: 'Pass@123'
          }
        }

        expect {
          post '/registrations', params: params
        }.to_not change(User, :count)
      end

      it 'when cpf already exist' do
        cpf = '79027123020'
        create(:user, cpf: cpf)

        params = {
          user: {
            name: 'Maria',
            surname: 'Li',
            date_of_birth: '31/12/1999',
            phone: '11123456789',
            email_address: 'valid@email.com',
            cpf: cpf,
            password: 'Pass@123'
          }
        }

        expect {
          post '/registrations', params: params
        }.to_not change(User, :count)
      end
    end
  end
end
