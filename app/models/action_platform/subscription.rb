# == Schema Information
#
# Table name: action_platform_subscriptions
#
#  id              :integer          not null, primary key
#  contact_id      :integer          not null
#  platform_id     :integer          not null
#  order_id        :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organization_id :integer          not null
#  status          :integer          not null
#  expires_on      :date
#

class ActionPlatform::Subscription < ActiveRecord::Base
  belongs_to :contact
  belongs_to :platform
  belongs_to :order
  belongs_to :organization

  validates :contact, presence: true
  validates :platform, presence: true
  validates :order, presence: true
  validates :organization, presence: true
  validates :expires_on, presence: true

  enum status: {
    pending: 0,
    approved: 1,
  }

  after_initialize do
    self.status ||= "pending"
  end

  scope :active, -> { approved.where("expires_on >= ?", Date.today) }
  scope :for_contact, -> (contact) { active.where(contact: contact) }

  def expired?
    Date.today > expires_on
  end

  def self.has_active_subscription?(contact)
    active.for_contact(contact).any?
  end

  def self.for_contact(contact)
    where(contact: contact)
  end

  def self.for(organization:)
    joins(:order).
      includes(:platform).
      where("action_platform_orders.organization_id" => organization.id).
      flat_map { |subscription| subscription.platform }
  end

end
