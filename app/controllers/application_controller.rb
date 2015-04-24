class ApplicationController < ActionController::Base
  include DeviseTokenAuth::Concerns::SetUserByToken
  force_ssl
  #after_action :allow_amt_iframe

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # Amazon mech turk
  # def current_user
  #   #session[:current_user_id].nil? ? nil : User.find(session[:current_user_id])
  #   User.find(session[:current_user_id]) unless session[:current_user_id].nil?
  # end

  # private
  # def allow_amt_iframe
  #   response.headers['X-Frame-Options'] = 'ALLOW-FROM https://workersandbox.mturk.com'
  # end
end
