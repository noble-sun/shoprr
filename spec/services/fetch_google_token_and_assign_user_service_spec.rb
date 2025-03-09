require 'rails_helper'

RSpec.describe FetchGoogleTokenAndAssignUserService, type: :service do
  describe '#call' do
    context 'when client return valid token' do
      context "when the user doesn't exist" do
        it 'successfully create a new user and identity_provider' do
          response_hash = {
            "access_token" => "ya29.a0AeXRPp4PQYlm775",
            "expires_in" => 3599,
            "refresh_token" => "ODExMjAwNzcyNTIzLWxrN2J0N3ZqcGg1NGFuZ2l",
            "scope" => "https://www.googleapis.com/auth/userinfo.email
            https://www.googleapis.com/auth/userinfo.profile openid",
            "token_type" => "Bearer",
            "id_token" => "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMDEwNTAzMTU4MjQ4NDY
                          1NDY0MTkiLCJlbWFpbCI6InZhbGlkLWdvb2dsZS1lbWFpbEBnbWFp
                          bC5jb20iLCJuYW1lIjoiSGFuayBHcmVlbiIsImdpdmVuX25hbWUiO
                          iJIYW5rIiwiZmFtaWx5X25hbWUiOiJHcmVlbiJ9.sl6z79-P6AhaO
                          p13kQE_HppgRorm6UqHCQn8z29Bl44"
          }
          allow_any_instance_of(IdentityProviders::GoogleClient)
            .to receive(:fetch_token).and_return(response_hash)

          result = described_class.call(code: 'valid-code')

          user = User.last
          expect(result.success?).to be_truthy
          expect(result.user).to eq(user)
          expect(IdentityProvider.count).to eq(1)
          expect(User.count).to eq(1)
          expect(user.identity_provider).to_not be_nil
        end
      end

      context 'when user already exist' do
        it 'successfully return update identity_provider' do
          user = create(:user)
          provider = create(:identity_provider,
            user: user, account_identifier: "101050315824846546419"
          )

          response_hash = {
            "access_token" => "ya29.a0AeXRPp4PQYlm775",
            "expires_in" => 3599,
            "refresh_token" => "ODExMjAwNzcyNTIzLWxrN2J0N3ZqcGg1NGFuZ2l",
            "scope" => "https://www.googleapis.com/auth/userinfo.email
            https://www.googleapis.com/auth/userinfo.profile openid",
            "token_type" => "Bearer",
            "id_token" => "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMDEwNTAzMTU4MjQ4NDY
                          1NDY0MTkiLCJlbWFpbCI6InZhbGlkLWdvb2dsZS1lbWFpbEBnbWFp
                          bC5jb20iLCJuYW1lIjoiSGFuayBHcmVlbiIsImdpdmVuX25hbWUiO
                          iJIYW5rIiwiZmFtaWx5X25hbWUiOiJHcmVlbiJ9.sl6z79-P6AhaO
                          p13kQE_HppgRorm6UqHCQn8z29Bl44"
          }
          allow_any_instance_of(IdentityProviders::GoogleClient)
            .to receive(:fetch_token).and_return(response_hash)

          parsed_token = [ {
            "sub" => "101050315824846546419",
            "email" => "valid-google-email@gmail.com",
            "name" => "Hank Green",
            "given_name" => "Hank",
            "family_name" => "Green"
          } ]
          allow(JWT).to receive(:decode).and_return(parsed_token)

          expect { described_class.call(code: 'valid-code') }.to_not change(User, :count)

          provider.reload
          expect(IdentityProvider.count).to eq(1)
          expect(provider.account_identifier).to eq(parsed_token.first['sub'])
          expect(provider.access_token).to eq(response_hash['access_token'])
          expect(provider.refresh_token).to eq(response_hash['refresh_token'])
          expect(provider.id_token).to eq(response_hash['id_token'])
        end
      end

      context 'when an error occurred' do
        context "when it's a client error" do
          it 'return a treated error message and status' do
            allow_any_instance_of(IdentityProviders::GoogleClient)
              .to receive(:fetch_token)
              .and_raise(IdentityProviders::GoogleClient::OAuthClientError)

            result = described_class.call(code: 'valid-code')

            expect(result.success?).to be_falsy
            expect(result.error).to eq('Could not use client. Please check your credentials.')
          end
        end

        context "when it's a permission error" do
          it 'return a treated error message and status' do
            allow_any_instance_of(IdentityProviders::GoogleClient)
              .to receive(:fetch_token)
              .and_raise(IdentityProviders::GoogleClient::OAuthGrantError)

            result = described_class.call(code: 'invalid-code')

            expect(result.success?).to be_falsy
            expect(result.error).to eq('Could not grant permission. Please inform valid code.')
          end
        end

        context "when it's a redirect error" do
          it 'return a treated error message and status' do
            allow_any_instance_of(IdentityProviders::GoogleClient)
              .to receive(:fetch_token)
              .and_raise(IdentityProviders::GoogleClient::OAuthRedirectError)

            result = described_class.call(code: 'valid-code')

            expect(result.success?).to be_falsy
            expect(result.error).to eq('Mismatch redirect uri. Please check redirect uri on google client app.')
          end
        end

        context "when it's an unexpected error" do
          it 'return a treated error message and status' do
            allow_any_instance_of(IdentityProviders::GoogleClient)
              .to receive(:fetch_token)
              .and_raise(StandardError, 'something went terribly wrong')

            result = described_class.call(code: 'valid-code')

            expect(result.success?).to be_falsy
            expect(result.error).to eq('Unexpected error: something went terribly wrong')
          end
        end
      end
    end
  end
end
