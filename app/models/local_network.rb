class LocalNetwork < ActiveRecord::Base
  validates_presence_of :name
  # has_and_belongs_to_many :countries
  has_many :countries
  has_many :contacts
  belongs_to :manager, :class_name => "Contact"
  
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
