# == Schema Information
#
# Table name: contributions
#
#  id                 :integer          not null
#  contribution_id    :string(255)      not null, primary key
#  invoice_code       :string(255)
#  raw_amount         :integer
#  recognition_amount :integer
#  date               :date             not null
#  stage              :string(255)      not null
#  payment_type       :string(255)
#  organization_id    :integer          not null
#  campaign_id        :string(255)
#  is_deleted         :boolean          default(FALSE), not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class Contribution < ActiveRecord::Base
  set_primary_key :contribution_id
  belongs_to :organization
  belongs_to :campaign

  validates_presence_of :contribution_id
  validates_presence_of :date
  validates_presence_of :stage
  validates_presence_of :organization_id

  scope :not_deleted, -> { where(is_deleted: false) }
  scope :visible_in_dashboard, -> { not_deleted.order('contributions.date DESC') }

  def amount
    recognition_amount || raw_amount
  end

  def invoice_id
    "#{invoice_code}#{organization_id}"
  end

  def campaign_name
    campaign ? campaign.name : nil
  end

  def deleted?
    self.is_deleted
  end
end
