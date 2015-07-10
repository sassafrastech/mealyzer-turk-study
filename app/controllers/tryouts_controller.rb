# Page allowing experimenters to try out the various conditions.
class TryoutsController < ApplicationController
  def index
    reset_session
    @fake_turk_params = Hash[*%w(workerId assignmentId hitId).map{ |k| [k, (User.maximum(k) || 0).to_i + 1] }.flatten]
  end
end
