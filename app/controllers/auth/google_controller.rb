class Auth::GoogleController < ApplicationController
  allow_unauthenticated_access only: [ :authenticate, :callback ]

  def authenticate
    authentication_url, state = IdentityProviders::GoogleClient.new.authorization_url

    session["anti_forgery_state"] = state

    redirect_to authentication_url, allow_other_host: true
  end

  def callback
    if params[:state] != session["anti_forgery_state"]
      Rails.logger.error "state #{params[:state]} does not match anti forgery state."

      redirect_to new_session_path, notice: "Sorry, could not go through the authentication. Try again."; return
    end

    result = FetchGoogleTokenAndAssignUserService.call(code: params[:code])

    if result.success?
      start_new_session_for(result.user)
      redirect_to after_authentication_url
    else
      redirect_to new_session_path, alert: result.error
    end
  end
end
