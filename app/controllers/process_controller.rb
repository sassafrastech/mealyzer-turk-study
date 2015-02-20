class ProcessController < ApplicationController

  def create
    Rails.logger.debug("We are in create now")
    Rails.logger.debug(params)
  end

end