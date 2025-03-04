require 'rails_helper'

RSpec.describe IdentityProviders::GoogleClient do
  describe '#authorization_url' do
    context 'when defining params for authorization url' do
      it 'return authorization url with correct params and anti forgery state' do
        client = described_class.new.authorization_url

        authorization_url = URI(client.first)
        expect(authorization_url.host).to eq('accounts.google.com')
        expect(authorization_url.path).to eq('/o/oauth2/v2/auth')

        parsed_params = CGI.parse(authorization_url.query)
        expect(parsed_params).to match(
          hash_including('client_id', 'redirect_uri', 'response_type', 'scope', 'state')
        )
        expect(parsed_params['redirect_uri'].first).to eq(auth_google_callback_url)
        expect(parsed_params['state'].first).to eq(client.second)
        expect(parsed_params['scope'].first).to eq('openid email profile')
        expect(parsed_params['access_type'].first).to eq('offline')
      end
    end
  end

  describe '#fetch_token' do
    context 'when requesting token' do
      it 'initializes OAuth2::Client with correct parameters' do
        client_id = 'google-client-id'
        client_secret = 'google-client-secret'
        google_base_url = 'google-client-id'

        stub_const('ENV', ENV.to_h.merge({
          'GOOGLE_CLIENT_ID' => client_id,
          'GOOGLE_CLIENT_SECRET'=> client_secret,
          'GOOGLE_OAUTH2_BASE_URL' => google_base_url
        }))

        oauth2_client_double = instance_double(OAuth2::Client)
        allow(OAuth2::Client).to receive(:new).and_return(oauth2_client_double)

        auth_code_strategy_double = instance_double(OAuth2::Strategy::AuthCode)
        allow(oauth2_client_double).to receive(:auth_code).and_return(auth_code_strategy_double)

        access_token_double = instance_double(OAuth2::AccessToken)
        allow(auth_code_strategy_double).to receive(:get_token).and_return(access_token_double)

        oauth2_response_double = instance_double(OAuth2::Response, status: 200)
        allow(access_token_double).to receive(:response).and_return(oauth2_response_double)

        response_hash = {
          "access_token" => "ya29.a0AeXRPp4PQYlm775",
          "expires_in" => 3599,
          "scope" => "https://www.googleapis.com/auth/userinfo.email
            https://www.googleapis.com/auth/userinfo.profile openid",
          "token_type" => "Bearer",
          "id_token" => "id_token-1324asdf"
        }
        allow(oauth2_response_double).to receive(:parsed).and_return(response_hash)

        described_class.new.fetch_token(code: 'code')

        expect(OAuth2::Client).to have_received(:new).with(
          client_id, client_secret, {
            site: google_base_url,
            token_url: '/token',
            authorize_url: '/o/oauth2/v2/auth'
          }
        )
      end

      it 'return successfull response ' do
        code = '4/0AQSTgQE4Mu-T-p-1rN-yWnfGh5axbGzTkOfPzSZVrNTYS7Lbd22exbGFIdqTlDTcPLb7Yw'

        oauth2_client_double = instance_double(OAuth2::Client)
        allow(OAuth2::Client).to receive(:new).and_return(oauth2_client_double)

        auth_code_strategy_double = instance_double(OAuth2::Strategy::AuthCode)
        allow(oauth2_client_double).to receive(:auth_code).and_return(auth_code_strategy_double)

        access_token_double = instance_double(OAuth2::AccessToken)
        allow(auth_code_strategy_double).to receive(:get_token).and_return(access_token_double)

        oauth2_response_double = instance_double(OAuth2::Response, status: 200)
        allow(access_token_double).to receive(:response).and_return(oauth2_response_double)

        response_hash = {
          "access_token" => "ya29.a0AeXRPp4PQYlm775",
          "expires_in" => 3599,
          "refresh_token" => "ODExMjAwNzcyNTIzLWxrN2J0N3ZqcGg1NGFuZ2l",
          "scope" => "https://www.googleapis.com/auth/userinfo.email
            https://www.googleapis.com/auth/userinfo.profile openid",
          "token_type" => "Bearer",
          "id_token" => "id_token-1324asdf"
        }
        allow(oauth2_response_double).to receive(:parsed).and_return(response_hash)

        response = described_class.new.fetch_token(code: code).response

        expect(response).to eq(oauth2_response_double)
        expect(response.parsed).to match(
          hash_including('access_token', 'id_token', 'scope', 'token_type', 'expires_in', 'refresh_token')
        )
        expect(auth_code_strategy_double).to have_received(:get_token).with(
          code, redirect_uri: auth_google_callback_url, grant_type: 'authorization_code'
        )
      end

      context 'when client_id is not valid' do
        it 'return invalid request error' do
          stub_request(:post, 'https://oauth2.googleapis.com/token').and_raise(
            OAuth2::Error.new({
              "error": "invalid_client",
              "error_description": "The OAuth client was not found."
            }.to_json)
          )

          expect { described_class.new.fetch_token(code: 'code') }.to raise_error(
            IdentityProviders::GoogleClient::OAuthClientError
          ) do |error|
            expect(error.message).to eq('Google client error: The OAuth client was not found.')
          end
        end
      end

      context 'when client_secret is not valid' do
        it 'return invalid request error' do
          stub_request(:post, 'https://oauth2.googleapis.com/token').and_raise(
            OAuth2::Error.new({
              "error": "invalid_client",
              "error_description": "Unauthorized"
            }.to_json)
          )

          expect { described_class.new.fetch_token(code: 'code') }.to raise_error(
            IdentityProviders::GoogleClient::OAuthClientError
          ) do |error|
            expect(error.message).to eq('Google client error: Unauthorized')
          end
        end
      end

      context 'when code is not valid' do
        it 'return invalid permission error' do
          stub_request(:post, 'https://oauth2.googleapis.com/token').and_raise(
            OAuth2::Error.new({
              "error": "invalid_grant",
              "error_description": "Bad Request"
            }.to_json)
          )

          expect { described_class.new.fetch_token(code: 'code') }.to raise_error(
            IdentityProviders::GoogleClient::OAuthGrantError
          ) do |error|
            expect(error.message).to eq('Google authorization error: Bad Request')
          end
        end
      end

      context 'when redirect_uri is not tha same as configured on client app' do
        it 'return wrong redirect uri error' do
          stub_request(:post, 'https://oauth2.googleapis.com/token').and_raise(
            OAuth2::Error.new({
              "error": "redirect_uri_mismatch",
              "error_description": "Bad Request"
            }.to_json)
          )

          expect { described_class.new.fetch_token(code: 'code') }.to raise_error(
            IdentityProviders::GoogleClient::OAuthRedirectError
          ) do |error|
            expect(error.message).to eq('mismatch redirect uri on client app error: Bad Request')
          end
        end
      end
    end
  end

  describe '#revoke_access' do
    context 'when making request to revoke access with valid access token' do
      it 'successfully remove access of account' do
        google_base_url = 'https://oauth2.googleapis.com'
        stub_const('ENV', ENV.to_h.merge({
          'GOOGLE_OAUTH2_BASE_URL' => google_base_url
        }))
        user = create(:user)
        access_token = 'access-token-1234asdf'
        identity_provider = create(:identity_provider,
                                   user: user,
                                   access_token: access_token
                                  )

        net_httpok_double = instance_double(Net::HTTPOK)
        allow(Net::HTTP).to receive(:post_form).and_return(net_httpok_double)

        response = described_class.new.revoke_access(user:)

        expect(Net::HTTP).to have_received(:post_form).with(
          URI("#{google_base_url}/revoke"), 'token' => access_token
        )
        expect(response).to eq(net_httpok_double)
      end
    end

    context 'when access token is expired' do
      it 'successfully refresh access token and revoke access' do
        user = create(:user)
        access_token = 'access-token-1234asdf'
        refresh_token = 'refresh-token-123'
        expires_in = DateTime.now - 1.day
        identity_provider = create(
          :identity_provider,
          user: user,
          access_token: access_token,
          refresh_token: refresh_token,
          expires_in: expires_in
        )

        oauth2_client_double = instance_double(OAuth2::Client)
        allow(OAuth2::Client).to receive(:new).and_return(oauth2_client_double)

        auth_code_strategy_double = instance_double(OAuth2::Strategy::AuthCode)
        allow(oauth2_client_double).to receive(:auth_code).and_return(auth_code_strategy_double)

        access_token_double = instance_double(OAuth2::AccessToken)
        allow(auth_code_strategy_double).to receive(:get_token).and_return(access_token_double)

        oauth2_response_double = instance_double(OAuth2::Response, status: 200)
        allow(access_token_double).to receive(:response).and_return(oauth2_response_double)

        response_hash = {
          "refresh_toke" => "refresh-token-123",
          "access_token" => "updated-token-ya29.a0AeXRPp4PQYlm775",
          "expires_in" => 3599,
          "scope" => "https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/userinfo.profile openid",
          "token_type" => "Bearer",
          "id_token" => "id_token-1324asdf"
        }
        allow(oauth2_response_double).to receive(:parsed).and_return(response_hash)

        net_httpok_double = instance_double(Net::HTTPOK)
        allow(Net::HTTP).to receive(:post_form).and_return(net_httpok_double)

        described_class.new.revoke_access(user:)

        expect(identity_provider.access_token).to eq("updated-token-ya29.a0AeXRPp4PQYlm775")
        expect(identity_provider.expires_in).to be_within(1.second).of(DateTime.now + 3599.seconds)
        expect(Net::HTTP).to have_received(:post_form).with(
          URI("https://oauth2.googleapis.com/revoke"), 'token' => identity_provider.access_token
        )
        expect(auth_code_strategy_double).to have_received(:get_token).with(
          nil, grant_type: 'refresh_token', refresh_token: refresh_token
        )
      end
    end
  end
end
