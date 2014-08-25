require 'rails_helper'
require 'pp'

describe User do
  context "no users have been created" do

    it "should create a user of condition 1" do
      u = User.create
      expect(u.condition).to eq(1)
    end
  end

  context "all of condition 1 has been filled" do
    before do
      # Create five users of condition 1
      User::MIN_CONDITION.times do |u|
        User.create
      end
    end

    it "should create a user of condition 2" do
      u = User.create
      expect(u.condition).to eq(2)
    end
  end

  context "all of condition 1 and 2 have been filled" do
    before do
      # Create five users of condition 1
      (User::MIN_CONDITION * 2).times do |u|
        User.create
      end
    end

    it "should create a user with condition 6" do
      u = User.create
      expect(u.condition).to eq(6)
    end
  end

  context "after 1,2, and 6 have been filled, do the others" do
    before do
      (User::MIN_CONDITION * 300).times do |u|
        User.create
      end
    end

    it "should create a condition that isn't 1,2, 6" do
       u = User.create
      expect(u.condition).to_not eq(1 || 2 || 6)
    end
  end

end
