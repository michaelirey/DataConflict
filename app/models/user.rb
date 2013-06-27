class User < ActiveRecord::Base
  attr_accessible :email, :first, :last, :title

  include DataConflictCheck
end