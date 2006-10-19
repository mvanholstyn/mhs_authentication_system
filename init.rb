dir = File.join( File.dirname( __FILE__ ), 'lib' )

require_dependency File.join( dir, 'lwt_authentication_system' )
require_dependency File.join( dir, 'group' )
require_dependency File.join( dir, 'privilege' )
#require_dependency 'preference'

ActiveRecord::Base.extend LWT::AuthenticationSystem::Model::SingletonMethods
ActionController::Base.send :include, LWT::AuthenticationSystem::Controller
