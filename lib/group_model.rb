if( Group rescue true )
  class ::Group < ActiveRecord::Base
  end
end

Group.class_eval do
  has_many :users unless Group.reflect_on_association :users
  has_and_belongs_to_many :privileges unless Group.reflect_on_association :privileges

  validates_presence_of :name
end
