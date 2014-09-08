require 'rails_helper'
require 'pp'

RSpec.describe MatchAnswersController do

  describe "GET new" do
    it "assigns @user and @match_answer" do
      get :new
      expect(assigns(:user)).to be_a_new(User)
    end

  end


end