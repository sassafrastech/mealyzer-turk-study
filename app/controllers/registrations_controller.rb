class RegistrationsController < Devise::RegistrationsController
  protect_from_forgery :except => :create

  def create
    @user = User.create(params.require(:registration).require(:user).permit!)

    if @user.valid?
      Rails.logger.debug("Saved woo!")
      render nothing: true
    else
      Rails.logger.debug("error")
      Rails.logger.debug(@user.errors.full_messages)
      render json: { errors: @user.errors.full_messages }, status: 500
    end
  end

end