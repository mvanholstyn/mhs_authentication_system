class Group < ActiveRecord::Base
  has_many :users
  has_and_belongs_to_many :privileges
  
  validates_presence_of :name
end
