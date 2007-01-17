class UsersController < ApplicationController
  acts_as_login_controller

  redirect_after_login do |controller, user|
    raise "You need to add a after_login redirect"
    #{ :controller => "example" }
  end
end
