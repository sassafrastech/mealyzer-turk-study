class PushNotificationsController < ApplicationController
  protect_from_forgery :except => :subscribe

  def subscribe
    Rails.logger.debug(params)
    # find user
    @user = User.where(uid: params[:uid]).last
    if @user.nil?
      @user = User.create(uid: params[:uid], token: params[:token])
    end

    render :nothing => true
  end

end
