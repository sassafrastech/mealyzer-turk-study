class Api::PushNotificationsController < ApplicationController
  protect_from_forgery :except => :subscribe
  before_action :authenticate_user!

  def subscribe
    current_user.update_attribute(:push_notification_token, params[:token])
    render nothing: true
  end
end
