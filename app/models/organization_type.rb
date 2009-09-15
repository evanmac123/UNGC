# == Schema Information
#
# Table name: organization_types
#
#  id            :integer(4)      not null, primary key
#  name          :string(255)
#  type_property :integer(4)
#  created_at    :datetime
#  updated_at    :datetime
#

class OrganizationType < ActiveRecord::Base
  validates_presence_of :name
  
  NON_BUSINESS = 1
  BUSINESS = 2
  
  named_scope :non_business, :conditions => ['type_property=?', NON_BUSINESS]
  named_scope :business, :conditions => ['type_property=?', BUSINESS]
end
