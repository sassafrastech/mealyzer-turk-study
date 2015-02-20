class ProcessController < ApplicationController
  protect_from_forgery :except => :create

  def create
    Rails.logger.debug("We are in create now")
    Rails.logger.debug(params)
    render :nothing => true, :status => 200, :content_type => 'text/html'
  end

end