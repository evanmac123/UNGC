# == Schema Information
#
# Table name: countries
#
#  id                     :integer          not null, primary key
#  code                   :string(255)
#  name                   :string(255)
#  region                 :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#  manager_id             :integer
#  local_network_id       :integer
#  participant_manager_id :integer
#  regional_center_id     :integer

class Country < ActiveRecord::Base
  belongs_to :local_network
  belongs_to :regional_center, :class_name => 'LocalNetwork'
  belongs_to :manager, :class_name => 'Contact'
  belongs_to :participant_manager, :class_name => 'Contact'
  has_and_belongs_to_many :communication_on_progresses
  has_many :organizations

  validates_presence_of :name, :code, :region

  default_scope { order(:name) }

  REGIONS = { :africa           => 'Africa',
              :asia             => 'Asia',
              :europe           => 'Europe',
              :latin_america    => 'Latin America and the Caribbean',
              :mena             => 'MENA',
              :northern_america => 'Northern America',
              :oceania          => 'Oceania'
            }

  scope :where_region, lambda {|region| where(:region => region) }

  def self.regions
    Country.group(:region)
      .select(:region)
      .order(:region)
  end

  def self.data_for_select
    Country.order(:name).map { |c| [c.name, c.id] }
  end

  def region_for_select_field
    region.try(:to_sym)
  end

  def region_name
    REGIONS[self.region.to_sym] unless region.nil?
  end

  def local_network_name
    self.local_network.try(:name) || ''
  end

  def regional_manager_name
    self.manager.try(:name) || ''
  end

  def participant_manager_name
    self.participant_manager.try(:name) || ''
  end

end
