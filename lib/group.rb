class Group < ActiveRecord::Base
  has_many :users
  has_many :privileges, :through=>:group_privileges
  has_many :group_privileges, :dependent=>:destroy

  validates_presence_of :name
end
