class Privilege < ActiveRecord::Base
  has_and_belongs_to_many :groups

  validates_presence_of :name
end
