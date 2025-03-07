require 'rails_helper'

RSpec.describe 'Google Auth', type: :request do
  describe 'GET /authenticate' do
    context 'redirect to google authentication page and store state in session' do
      it 'successfully' do
        get auth_google_path

        url = URI(response.redirect_url)
        redirect_params = CGI.parse(url.query)
        expect(response).to redirect_to(match(url.host + url.path))
        expect(redirect_params).to match(
          hash_including('client_id', 'redirect_uri', 'response_type', 'scope', 'state')
        )
        expect(session['anti_forgery_state']).to_not be_nil
      end
    end
  end

  describe 'GET /callback' do
    context 'authenticate new user and redirects to root path' do
      it 'successfully' do
        allow_any_instance_of(Auth::GoogleController).to receive(:session).and_return({ 'anti_forgery_state' => 'valid-state' })

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
          "id_token" => "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMDEwNTAzMTU4MjQ4NDY
                        1NDY0MTkiLCJlbWFpbCI6InZhbGlkLWdvb2dsZS1lbWFpbEBnbWFp
                        bC5jb20iLCJuYW1lIjoiSGFuayBHcmVlbiIsImdpdmVuX25hbWUiO
                        iJIYW5rIiwiZmFtaWx5X25hbWUiOiJHcmVlbiJ9.sl6z79-P6AhaO
                        p13kQE_HppgRorm6UqHCQn8z29Bl44"
        }
        allow(oauth2_response_double).to receive(:parsed).and_return(response_hash)

        get auth_google_callback_path, params: { code: 'valid-code', state: 'valid-state' }

        user = User.last
        expect(response).to redirect_to(root_path)
        expect(User.count).to eq(1)
        expect(Session.count).to eq(1)
        expect(Session.last.user).to eq(user)
      end
    end

    context 'when anti forgery state does not match' do
      it 'redirect to login with a message' do
        allow_any_instance_of(Auth::GoogleController).to receive(:session)
          .and_return({ 'anti_forgery_state' => 'anti-forgery-state' })

        get auth_google_callback_path, params: { code: 'valid-code', state: 'wrong-state' }

        expect(response).to redirect_to(new_session_path)
        expect(flash[:notice]).to match("Sorry, could not go through the authentication. Try again.")
      end
    end

    context 'when an error occurred when getting the token' do
      it 'redirect to login with a alert message' do
        allow_any_instance_of(Auth::GoogleController).to receive(:session)
          .and_return({ 'anti_forgery_state' => 'anti-forgery-state' })

        oauth2_client_double = instance_double(OAuth2::Client)
        allow(OAuth2::Client).to receive(:new).and_return(oauth2_client_double)

        auth_code_strategy_double = instance_double(OAuth2::Strategy::AuthCode)
        allow(oauth2_client_double).to receive(:auth_code).and_return(auth_code_strategy_double)

        allow(auth_code_strategy_double).to receive(:get_token)
          .and_raise(IdentityProviders::GoogleClient::OAuthGrantError)

        get auth_google_callback_path, params: { code: 'invalid-code', state: 'anti-forgery-state' }

        expect(response).to redirect_to(new_session_path)
        expect(flash[:alert]).to match("Could not grant permission. Please inform valid code.")
      end
    end
  end
end
