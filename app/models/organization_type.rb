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

  OTHER = 0
  NON_BUSINESS = 1
  BUSINESS = 2
  PARTICIPANT = [1,2]
  ALL_ORGANIZATIONS = [0,1,2]

  TYPE_PROPERTIES = {
    0 => 'Other',
    1 => 'Non Business',
    2 => 'Business'
  }

  scope :non_business, -> { where(type_property: NON_BUSINESS) }
  scope :business, -> { where(type_property: BUSINESS) }
  scope :participants, -> { where(type_property: PARTICIPANT) }
  scope :staff_types, -> { where(type_property: ALL_ORGANIZATIONS) }

  FILTERS = {
    :academia         => 'Academic',
    :business_global  => 'Business Association Global',
    :business_local   => 'Business Association Local',
    :civil_global     => 'NGO Global',
    :civil_local      => 'NGO Local',
    :city             => 'City',
    :foundation       => 'Foundation',
    :labour_global    => 'Labour Global',
    :labour_local     => 'Labour Local',
    :public           => 'Public Sector Organization',
    :companies        => 'Company',
    :micro_enterprise => 'Micro Enterprise',
    :sme              => 'SME',
    :signatory        => 'Initiative Signatory'
  }

  NAME_MAPPINGS = {
    'SME' => 'Small or Medium-sized Enterprise'
  }

  def self.for_filter(*filter_types)
    names = Array(filter_types).map { |f| FILTERS[f] }
    where(name: names)
  end

  def business?
    type_property == BUSINESS
  end

  def non_business?
    type_property == NON_BUSINESS
  end

  def micro_enterprise?
    name == FILTERS[:micro_enterprise]
  end

  def self.micro_enterprise
    @_micro_enterprise ||= where(name: FILTERS[:micro_enterprise]).first
  end

  def self.sme
    @_sme ||= where(name: FILTERS[:sme]).first
  end

  def self.city
    @_city ||= where(name: FILTERS[:city]).first
  end

  def self.foundation
    @_foundation ||= where(name: FILTERS[:foundation]).first
  end

  def self.company
    @_foundation_type ||= where(name: FILTERS[:companies]).first
  end

  def self.academic
    @_academic ||= where(name: FILTERS[:academia]).first
  end

  def self.signatory
    @_signatory ||= where(name: FILTERS[:signatory]).first
  end

  def self.business_association
    @_business_association ||= for_filter(:business_global, :business_local)
  end

  def self.labour
    @_labor ||= for_filter(:labour_global, :labour_local)
  end

  def self.ngo
    @_ngo ||= for_filter(:civil_global, :civil_local, :foundation)
  end

  def self.public_sector
    @_public_sector ||= where(name: FILTERS[:public]).first
  end

  def type_description
    TYPE_PROPERTIES[type_property] || ''
  end

end
