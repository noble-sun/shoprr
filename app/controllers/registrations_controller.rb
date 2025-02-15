class RegistrationsController < ApplicationController
  allow_unauthenticated_access

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      start_new_session_for @user
      redirect_to root_path, notice: "sign up successfully!"
    else
      flash[:alert] = "Failed to sign up: #{@user.errors.full_messages.to_sentence}"
      redirect_to new_registration_path
    end
  end

  private

  def user_params
    params.require(:user).permit(:email_address, :cpf, :password)
  end
end
