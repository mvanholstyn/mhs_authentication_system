if not defined? Group
  class ::Group < ActiveRecord::Base
  end
end

Group.class_eval do
  has_many :users
  has_many :privileges, :through => :group_privileges
  has_many :group_privileges, :dependent => :destroy

  validates_presence_of :name
end
