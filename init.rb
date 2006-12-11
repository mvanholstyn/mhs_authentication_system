dir = File.join( File.dirname( __FILE__ ), 'lib' )

require( 'lwt_authentication_system' )
require( 'group' )
require( 'privilege' )
require( 'group_privilege' )
#require_dependency 'preference'

ActiveRecord::Base.extend LWT::AuthenticationSystem::Model::SingletonMethods
ActionController::Base.send :include, LWT::AuthenticationSystem::Controller
