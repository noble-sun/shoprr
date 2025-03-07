class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_url, alert: "Try again later." }

  def new
  end

  def create
    if user = User.authenticate_by(params.permit(:login, :password))
      start_new_session_for user
      redirect_to after_authentication_url
    else
      redirect_to new_session_path, alert: "Try another email address or password."
    end
  end

  def destroy
    if Current.user.identity_provider
      result = RevokeGoogleAccessService.call(user: Current.user)
      Rails.logger.warn result.error unless result.success?
    end

    terminate_session
    redirect_to new_session_path
  end
end
