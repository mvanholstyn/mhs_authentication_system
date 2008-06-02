dir = File.join( File.dirname( __FILE__), 'lib')

require File.join(dir, 'model')
require File.join(dir, 'controller')
require File.join(dir, 'login_controller')
require File.join(dir, 'group_model')
require File.join(dir, 'privilege_model')
require File.join(dir, 'user_reminder_model')
require File.join(dir, 'user_reminder_mailer_model')
ActiveRecord::Base.send :include, Mhs::AuthenticationSystem::Model
ActionController::Base.send :include, Mhs::AuthenticationSystem::Controller
ActionController::Base.send :include, Mhs::AuthenticationSystem::LoginController
