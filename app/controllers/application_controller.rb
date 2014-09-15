class ApplicationController < ActionController::Base
  force_ssl
  after_action :allow_amt_iframe

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def current_user
    User.find(session[:current_user_id])
  end

  private
  def allow_amt_iframe
    response.headers['X-Frame-Options'] = 'ALLOW-FROM https://workersandbox.mturk.com'
  end
end
