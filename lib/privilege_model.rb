if(Privilege rescue true)
  class ::Privilege < ActiveRecord::Base
  end
end

Privilege.class_eval do
  has_and_belongs_to_many :roles unless Role.reflect_on_association :roles

  validates_presence_of :name
end
