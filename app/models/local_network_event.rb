# == Schema Information
#
# Table name: local_network_events
#
#  id                               :integer(4)      not null, primary key
#  local_network_id                 :integer(4)
#  title                            :string(255)
#  description                      :text
#  date                             :date
#  event_type                       :string(255)
#  num_participants                 :integer(4)
#  gc_participant_percentage        :integer(4)
#  stakeholder_company              :boolean(1)
#  stakeholder_sme                  :boolean(1)
#  stakeholder_business_association :boolean(1)
#  stakeholder_labour               :boolean(1)
#  stakeholder_un_agency            :boolean(1)
#  stakeholder_ngo                  :boolean(1)
#  stakeholder_foundation           :boolean(1)
#  stakeholder_academic             :boolean(1)
#  stakeholder_government           :boolean(1)
#  stakeholder_media                :boolean(1)
#  stakeholder_others               :boolean(1)
#  created_at                       :datetime
#  updated_at                       :datetime
#

class LocalNetworkEvent < ActiveRecord::Base
  belongs_to :local_network
  has_and_belongs_to_many :principles
  has_one :attachment, :class_name => 'UploadedFile', :as => :attachable
  
  def local_network_model_type
    :knowledge_sharing
  end
  
end

