class LocalNetwork < ActiveRecord::Base
  validates_presence_of :name
  has_and_belongs_to_many :countries
  belongs_to :manager, :class_name => "Contact"
end
