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
  
  FILTERS = {
    :academia        => 'Academic',
    :business_global => 'Business Association Global',
    :business_local  => 'Business Association Local',
    :civil_global    => 'NGO Global',
    :civil_local     => 'NGO Local',
    :labour_global   => 'Labour Global',
    :labour_local    => 'Labour Local',
    :public          => 'Public Sector Organization'
  }
  
  def self.for_filter(filter_type)
    filter_array = [FILTERS[filter_type]].flatten
    find :all, :conditions => ["name IN (?)", filter_array]
  end
  
end
