# app/models/user.rb
class User < ActiveRecord::Base

  # notice this comes BEFORE the include statement below
  # also notice that :confirmable is not included in this block
  devise :database_authenticatable, :recoverable,
         :trackable, :validatable, :registerable

  # note that this include statement comes AFTER the devise block above
  include DeviseTokenAuth::Concerns::User

  before_save -> { skip_confirmation! }
end