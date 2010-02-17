# == Schema Information
#
# Table name: local_networks
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  manager_id :integer(4)
#  url        :string(255)
#  state      :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class LocalNetwork < ActiveRecord::Base
  validates_presence_of :name
  has_many :countries
  has_many :contacts
  belongs_to :manager, :class_name => "Contact"
  
  STATES = ['emerging', 'established', 'none']
  
  def latest_participant
    participants.find(:first, :order => 'joined_on DESC')
  end
  
  def network_contacts
    contacts.network_contacts + [manager]
  end
  
  def participants
    Organization.visible_in_local_network.where_country_id(countries.map(&:id))
  end
end
