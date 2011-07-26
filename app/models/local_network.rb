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
  validates_format_of :url,
                      :with => /^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/ix,
                      :message => "for website is invalid. Please enter one address in the format http://unglobalcompact.org/",
                      :unless => Proc.new { |local_network| local_network.url.blank? }
  
  default_scope :order => 'name'
  
  STATES = { :emerging => 'Emerging', :established => 'Established' }
  
  # To link to public profiles, we associate the two regional networks with their host countries
  # Ex: NetworksAroundTheWorld/local_network_sheet/AE.html
  REGION_COUNTRY = { 'Gulf States' => 'AE', 'Nordic Network' => 'DK' }
          
  def latest_participant
    participants.find(:first, :order => 'joined_on DESC')
  end
  
  def network_contacts
    contacts.network_contacts + [manager]
  end
  
  def participants
    Organization.visible_in_local_network.where_country_id(countries.map(&:id))
  end
  
  def humanize_state
    state.try(:humanize) || ''    
  end
  
  def state_for_select_field
    state.try(:to_sym)
  end
  
    
  def country_code
    if countries.count == 1
      countries.first.code
    end
  end
  
end
