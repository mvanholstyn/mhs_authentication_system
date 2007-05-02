dir = File.dirname( __FILE__ )

require 'rubygems'
require 'active_record'
require 'action_controller'
require 'action_mailer'
require 'test/unit'

require File.join( dir, '../init' )

ActiveRecord::Base.logger = Logger.new File.join( dir, 'log/test.log' )
ActiveRecord::Base.establish_connection YAML.load_file( File.join( dir, 'config/database.yml' ) )[:test]

ActiveRecord::Schema.suppress_messages do
  require File.join( dir, 'db/schema' )
end

class NormalUser < ActiveRecord::Base
end

class LwtAuthenticationSystemUser < ActiveRecord::Base
  acts_as_login_model
end

class NonValidatingLwtAuthenticationSystemUser < ActiveRecord::Base
  acts_as_login_model :group_validation => false, :password_validation => false, 
    :username_validation => false, :username_unique_validation => false, 
    :email_address_validation => false, :email_address_unique_validation => false
end


