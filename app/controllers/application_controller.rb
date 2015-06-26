class ApplicationController < ActionController::Base
  include DeviseTokenAuth::Concerns::SetUserByToken

  before_action :mailer_set_url_options
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << :first_name << :last_name << :diabetes << :training << :training_stage
    devise_parameter_sanitizer.for(:account_update) << :token
  end

  # mailer is for some reason too stupid to figure these out on its own
  def mailer_set_url_options
    # copy options from the above method, and add a host option b/c mailer is especially stupid
    default_url_options.merge(:host => request.host_with_port).each_pair do |k,v|
      ActionMailer::Base.default_url_options[k] = v
    end
  end

  #force_ssl
  #after_action :allow_amt_iframe

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  #protect_from_forgery with: :exception

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
