module IdentityProviders
  class GoogleClient
    class OAuthClientError < StandardError; end
    class OAuthGrantError < StandardError; end
    class OAuthRedirectError < StandardError; end

    include Rails.application.routes.url_helpers

    def initialize
      @client_id = ENV["GOOGLE_CLIENT_ID"]
    end

    def authorization_url
      client = oauth2_client(base_url: ENV["GOOGLE_ACCOUNT_BASE_URL"])

      state = generate_anti_forgery_state

      auth_url = client.auth_code.authorize_url(
        access_type: "offline",
        redirect_uri: redirect_uri,
        scope: "openid email profile",
        state: state
      )

      [ auth_url, state ]
    end

    def fetch_token(code:)
      client = oauth2_client(
        client_secret: ENV["GOOGLE_CLIENT_SECRET"],
        base_url: ENV["GOOGLE_OAUTH2_BASE_URL"]
      )

      response = client.auth_code.get_token(
        code,
        redirect_uri: redirect_uri,
        grant_type: "authorization_code"
      )

      response.response.parsed
    rescue OAuth2::Error => e
      error = JSON.parse(e.body, symbolize_names: true)

      case error[:error]
      when "invalid_client"
        raise OAuthClientError, "Google client error: #{error[:error_description]}"
      when "invalid_grant"
        raise OAuthGrantError, "Google authorization error: #{error[:error_description]}"
      when "redirect_uri_mismatch"
        raise OAuthRedirectError, "mismatch redirect uri on client app error: #{error[:error_description]}"
      else
        raise OAuth2::Error, e.body
      end
    end

    def revoke_access(user:)
      provider = user.identity_provider

      if DateTime.now > provider.expires_in
        refresh_access_token(provider:)
      end

      Net::HTTP.post_form(revoke_url, "token" => user.identity_provider.access_token)
    end

    private

    def refresh_access_token(provider:)
      client = oauth2_client(
        client_secret: ENV["GOOGLE_CLIENT_SECRET"],
        base_url: ENV["GOOGLE_OAUTH2_BASE_URL"]
      )

      response = client.auth_code.get_token(
        nil,
        grant_type: "refresh_token",
        refresh_token: provider.refresh_token
      )

      parsed_response = response.response.parsed

      provider.update(
        access_token: parsed_response["access_token"],
        expires_in: (DateTime.now + parsed_response["expires_in"].seconds)
      )

    rescue OAuth2::Error => e
      error = JSON.parse(e.body, symbolize_names: true)

      case error[:error]
      when "invalid_client"
        raise OAuthClientError, "Google client error: #{error[:error_description]}"
      when "invalid_grant"
        raise OAuthGrantError, "invalid or expired refresh token: #{error[:error_description]}"
      else
        raise OAuth2::Error, e.body
      end
    end

    def revoke_url
      URI(ENV["GOOGLE_OAUTH2_BASE_URL"] + Rails.configuration.identity_provider[:google][:revoke_url])
    end

    def redirect_uri
      ENV["BASE_URL"] + auth_google_callback_path
    end

    def generate_anti_forgery_state
      SecureRandom.hex(15)
    end

    def oauth2_client(client_secret: nil, base_url:)
      OAuth2::Client.new(
        @client_id,
        client_secret,
        site: base_url,
        token_url: Rails.configuration.identity_provider[:google][:token_url],
        authorize_url: Rails.configuration.identity_provider[:google][:authorize_url]
      )
    end
  end
end
