dir = File.join( File.dirname( __FILE__ ), 'lib' )

unless defined? Group
  class Group < ActiveRecord::Base
  end
end

unless defined? Privilege
  class Privilege < ActiveRecord::Base
  end
end

unless defined? GroupPrivilege
  class GroupPrivilege < ActiveRecord::Base
  end
end

Group.class_eval do
  has_many :users
  has_many :privileges, :through=>:group_privileges
  has_many :group_privileges, :dependent=>:destroy

  validates_presence_of :name
end

Privilege.class_eval do
  has_many :groups, :through=>:group_privileges
  has_many :group_privileges, :dependent=>:destroy
  validates_presence_of :name
end

GroupPrivilege.class_eval do
  set_table_name "groups_privileges"
  belongs_to :group
  belongs_to :privilege
end

require File.join( dir, 'lwt_authentication_system' )
ActiveRecord::Base.extend LWT::AuthenticationSystem::Model::SingletonMethods
ActionController::Base.send :include, LWT::AuthenticationSystem::Controller
