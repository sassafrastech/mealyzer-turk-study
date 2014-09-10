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
        User.create(:num_tests => 28)
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
        User.create(:num_tests => 28)
      end
    end

    it "should create a user with condition 3" do
      u = User.create
      expect(u.condition).to eq(3)
    end
  end

  context "after 1,2, and 3 have been filled, do the others" do
    before do
      (User::MIN_CONDITION * 3).times do |u|
        User.create(:num_tests => 28)
      end
    end

    it "should create a condition that isn't 1,2, 6" do
       u = User.create
      expect(u.condition).to eq(4)
    end
  end

  context "A unique user" do
    it "should return unique is true" do
      user = User.create
      expect(user.unique?).to be(true)
    end
  end

  context "A returing user should not be unique" do
    it "should return false as unique" do
      user = User.create(:workerId => 123, :num_tests => 28)
      expect(user.unique?).to be(false)
    end

  end

end
