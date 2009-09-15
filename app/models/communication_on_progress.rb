# == Schema Information
#
# Table name: communication_on_progresses
#
#  id                  :integer(4)      not null, primary key
#  identifier          :string(255)
#  organization_id     :integer(4)
#  title               :string(255)
#  related_document    :string(255)
#  email               :string(255)
#  start_year          :integer(4)
#  facilitator         :string(255)
#  job_title           :string(255)
#  start_month         :integer(4)
#  end_month           :integer(4)
#  url1                :string(255)
#  url2                :string(255)
#  url3                :string(255)
#  added_on            :date
#  modified_on         :date
#  contact_name        :string(255)
#  end_year            :integer(4)
#  status              :integer(4)
#  include_ceo_letter  :boolean(1)
#  include_actions     :boolean(1)
#  include_measurement :boolean(1)
#  use_indicators      :boolean(1)
#  cop_score_id        :integer(4)
#  use_gri             :boolean(1)
#  has_certification   :boolean(1)
#  notable_program     :boolean(1)
#  created_at          :datetime
#  updated_at          :datetime
#

class CommunicationOnProgress < ActiveRecord::Base
  validates_presence_of :organization_id, :title
  belongs_to :organization
  has_and_belongs_to_many :languages
  has_and_belongs_to_many :countries
  has_and_belongs_to_many :principles

  named_scope :visible_to, lambda { |user|
    if user.user_type == Contact::TYPE_ORGANIZATION
      { :conditions => ['organization_id=?', user.organization_id] }
    else
      # TODO implement for network
      {}
    end
  }
end
