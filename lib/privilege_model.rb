if( Privilege rescue true )
  class ::Privilege < ActiveRecord::Base
  end
end

Privilege.class_eval do
  has_and_belongs_to_many :groups unless Group.reflect_on_association :groups
  
  validates_presence_of :name
end
