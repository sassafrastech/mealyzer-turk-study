class Api::PushNotificationsController < ApplicationController
  protect_from_forgery :except => :subscribe
  before_action :authenticate_user!

  def subscribe
    # find user
    Rails.logger.debug("Current user? #{current_user}")
    current_user.update_attributes(token: params[:token])

    # @user = User.where(uid: params[:uid]).last
    # if @user.nil?
    #   @user = User.create(uid: params[:uid], token: params[:token])
    # end

    render :nothing => true
  end

end
