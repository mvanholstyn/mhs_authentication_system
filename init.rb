dir = File.join( File.dirname( __FILE__ ), 'lib' )

require File.join( dir, 'model' )
require File.join( dir, 'controller' )
require File.join( dir, 'login_controller' )
ActiveRecord::Base.send :include, LWT::AuthenticationSystem::Model
ActionController::Base.send :include, LWT::AuthenticationSystem::Controller
ActionController::Base.send :include, LWT::AuthenticationSystem::LoginController
