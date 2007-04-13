if( Privilege rescue true )
  class ::Privilege < ActiveRecord::Base
  end
end

Privilege.class_eval do
  has_many :groups, :through => :group_privileges
  has_many :group_privileges, :dependent => :destroy
  
  validates_presence_of :name
end
