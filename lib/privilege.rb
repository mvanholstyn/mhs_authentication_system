class Privilege < ActiveRecord::Base
  has_many :groups, :through=>:group_privileges
  has_many :group_privileges, :dependent=>:destroy
  validates_presence_of :name
end
