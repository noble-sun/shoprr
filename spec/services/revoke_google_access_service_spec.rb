require 'rails_helper'

RSpec.describe RevokeGoogleAccessService, type: :service do
  describe '#call' do
    context 'when access token is not expired' do
      it 'successfully revoke access' do
        user = create(:user)
        create(:identity_provider, user: user, expires_in: DateTime.now + 1.day)

        allow_any_instance_of(IdentityProviders::GoogleClient)
          .to receive(:revoke_access).and_return(Net::HTTPOK.new(nil, 200, nil))

        result = described_class.call(user:)

        expect(result.success?).to be_truthy
      end
    end

    context 'when access token is expired' do
      it 'successfully request refresh token and then revoke access' do
        user = create(:user)
        create(:identity_provider, user: user, expires_in: DateTime.now - 1.day)

        client_double = instance_double(IdentityProviders::GoogleClient)
        allow(IdentityProviders::GoogleClient).to receive(:new).and_return(client_double)

        allow(client_double).to receive(:revoke_access).and_return(Net::HTTPOK.new(nil, 200, nil))
        allow(client_double).to receive(:refresh_access_token).and_return(true)

        result = described_class.call(user:)

        expect(result.success?).to be_truthy
        expect(client_double).to have_received(:refresh_access_token)
      end
    end

    context 'when an error occurred' do
      context 'when it is a client error' do
        it 'return a treated error message' do
          user = create(:user)
          create(:identity_provider, user:, expires_in: DateTime.now - 1.day)

          allow_any_instance_of(IdentityProviders::GoogleClient)
            .to receive(:refresh_access_token)
            .and_raise(IdentityProviders::GoogleClient::OAuthClientError)

          result = described_class.call(user:)

          expect(result.success?).to be_falsy
          expect(result.error).to eq('Could not use client. Please check your credentials.')
        end
      end

      context 'when it is a permission error' do
        it 'return a treated error message' do
          user = create(:user)
          create(:identity_provider, user:, expires_in: DateTime.now - 1.day)

          allow_any_instance_of(IdentityProviders::GoogleClient)
            .to receive(:refresh_access_token)
            .and_raise(IdentityProviders::GoogleClient::OAuthGrantError)

          result = described_class.call(user:)

          expect(result.success?).to be_falsy
          expect(result.error).to eq('Refresh token is invalid or expired. Please check your google account to revoke access.')
        end
      end

      context 'when it is a token error' do
        it 'return a treated error message' do
          user = create(:user)
          create(:identity_provider, user:)

          allow_any_instance_of(IdentityProviders::GoogleClient)
            .to receive(:revoke_access)
            .and_raise(IdentityProviders::GoogleClient::OAuthUnrevokableError)

          result = described_class.call(user:)

          expect(result.success?).to be_falsy
          expect(result.error).to eq('Token provided could not be used to revoke access.')
        end
      end

      context 'when it is an unexpected error' do
        it 'return a treated error message' do
          user = create(:user)
          create(:identity_provider, user:, expires_in: DateTime.now - 1.day)

          allow_any_instance_of(IdentityProviders::GoogleClient)
            .to receive(:refresh_access_token)
            .and_raise(StandardError, 'a very unexpected error.')

          result = described_class.call(user:)

          expect(result.success?).to be_falsy
          expect(result.error).to eq('Unexpected error: a very unexpected error.')
        end
      end
    end
  end
end
