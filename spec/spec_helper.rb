unless defined?(RAILS_ROOT)
 RAILS_ROOT = ENV["RAILS_ROOT"] || File.expand_path(File.join(File.dirname(__FILE__), "../../../.."))
end
require File.join(RAILS_ROOT, "spec", "spec_helper")
# require File.join(File.dirname(__FILE__), "..", "init")

ActionController::Routing::Routes.clear!
ActionController::Routing::Routes.draw {|m| m.connect ':controller/:action/:id' }
ActionController::Routing.use_controllers! %w(users account admin/users)

ActiveRecord::Base.logger = Logger.new File.join( dir, 'log/test.log' )
ActiveRecord::Base.establish_connection YAML.load_file( File.join( dir, 'config/database.yml' ) )[:test]

ActiveRecord::Schema.suppress_messages do
  require File.join( dir, 'db/schema' )
end

# class UsersController < ActionController::Base
# end
# 
# class AccountController < ActionController::Base
# end
# 
# module Admin
#   class UsersController < ActionController::Base
#   end
# end


