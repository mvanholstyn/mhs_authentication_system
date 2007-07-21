require 'fileutils'

# Lets load up a rails environment
unless defined?(RAILS_ROOT)
 RAILS_ROOT = ENV["RAILS_ROOT"] || File.expand_path(File.join(File.dirname(__FILE__), "../../../.."))
end
require File.join(RAILS_ROOT, "spec", "spec_helper")
# require File.join(File.dirname(__FILE__), "..", "init")

# Setup up routes for our tests
ActionController::Routing::Routes.clear!
ActionController::Routing::Routes.draw {|m| m.connect ':controller/:action/:id' }
ActionController::Routing.use_controllers! %w(users account admin/users)

# Setup logging and db connection
FileUtils.mkdir( File.join( File.dirname(__FILE__), 'tmp' ) )
ActiveRecord::Base.logger = Logger.new File.join( File.dirname(__FILE__), 'tmp/test.log' )
ActiveRecord::Base.establish_connection :adapter => 'sqlite3', :database => File.join( File.dirname(__FILE__), 'tmp/test.db' )

# Load schema
ActiveRecord::Schema.suppress_messages do
  ActiveRecord::Schema.define do
    create_table :groups do |t|
      t.column :name, :string
    end

    create_table :privileges do |t|
      t.column :name, :string
    end

    create_table :groups_privileges do |t|
      t.column :group_id, :integer
      t.column :privilege_id, :integer
    end

    create_table :users do |t|
      t.column :username, :string
      t.column :password_hash, :string
      t.column :group_id, :integer
      t.column :email_address, :string
      t.column :active, :boolean
    end
  
    create_table :user_reminders do |t|
      t.column :user_id, :integer
      t.column :token, :string
      t.column :expires_at, :datetime
    end
  end
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


