# == Schema Information
#
# Table name: organization_types
#
#  id            :integer          not null, primary key
#  name          :string(255)
#  type_property :integer
#  created_at    :datetime
#  updated_at    :datetime
#

class OrganizationType < ActiveRecord::Base
  validates_presence_of :name
  has_many :organizations

  NON_BUSINESS = 1
  BUSINESS = 2
  PARTICIPANT = [1,2]
  ALL_ORGANIZATIONS = [0,1,2]

  scope :non_business, where('type_property=?', NON_BUSINESS)
  scope :business, where('type_property=?', BUSINESS)
  scope :participants, where('type_property in (?)', PARTICIPANT)
  scope :staff_types, where("type_property in (?)", ALL_ORGANIZATIONS)

  FILTERS = {
    :academia         => 'Academic',
    :business_global  => 'Business Association Global',
    :business_local   => 'Business Association Local',
    :civil_global     => 'NGO Global',
    :civil_local      => 'NGO Local',
    :city             => 'City',
    :foundation       => 'Foundation',
    :gc_networks      => 'GC Networks',
    :labour_global    => 'Labour Global',
    :labour_local     => 'Labour Local',
    :public           => 'Public Sector Organization',
    :companies        => 'Company',
    :micro_enterprise => 'Micro Enterprise',
    :sme              => 'SME',
    :signatory        => 'Initiative Signatory'
  }

  def self.for_filter(*filter_types)
    if filter_types.is_a?(Array)
      filter_types.map! { |f| FILTERS[f] }
      where("name IN (?)", filter_types)
    else
      where("name = ?", FILTERS[filter_types])
    end
  end    

  def business?
    type_property == BUSINESS
  end

  def non_business?
    type_property == NON_BUSINESS
  end

  def self.micro_enterprise
    where(name: FILTERS[:micro_enterprise]).first
  end

  def self.sme
    where(name: FILTERS[:sme]).first
  end

  def self.city
    first :conditions => {:name => FILTERS[:city]}
  end

  def self.company
    where(name: FILTERS[:companies]).first
  end

  def self.academic
    where(name: FILTERS[:academia]).first
  end

  def self.signatory
    where(name: FILTERS[:signatory]).first
  end

end
