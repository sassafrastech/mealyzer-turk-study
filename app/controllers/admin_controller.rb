class AdminController < ApplicationController
  def index
    response.headers['Cache-Control'] = 'no-cache, max-age=0, must-revalidate, no-store'
    reset_session
    session[:tryout_mode] = true
    @fake_turk_params = Hash[*%w(workerId assignmentId hitId).map{ |k| [k, SecureRandom.hex] }.flatten]
    @stats = User.group(:study_id, :study_phase, :condition, :complete).
      order(:study_id, :study_phase, :condition, :complete).count
    @studies = (@stats.keys.map{ |k| k[0] } << Settings.study_id).uniq.sort
  end

  def exit
    reset_session
    redirect_to root_path
  end
end
