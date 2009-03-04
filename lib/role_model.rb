if(Role rescue true)
  class ::Role < ActiveRecord::Base
  end
end

Role.class_eval do
  has_many :users unless Role.reflect_on_association :users
  has_and_belongs_to_many :privileges unless Role.reflect_on_association :privileges

  validates_presence_of :name
end
