dir = File.join( File.dirname( __FILE__ ), 'lib' )

require File.join( dir, 'model' )
require File.join( dir, 'controller' )
require File.join( dir, 'login_controller' )
require File.join( dir, 'group_model' )
require File.join( dir, 'privilege_model' )
require File.join( dir, 'group_privilege_model' )
require File.join( dir, 'forgot_password_model' )
require File.join( dir, 'forgot_password_mailer_model' )
ActiveRecord::Base.send :include, LWT::AuthenticationSystem::Model
ActionController::Base.send :include, LWT::AuthenticationSystem::Controller
ActionController::Base.send :include, LWT::AuthenticationSystem::LoginController
