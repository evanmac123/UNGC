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

  def expired?
    Date.today > expires_on
  end

  def self.for(organization:)
    joins(:order).
      includes(:platform).
      where("action_platform_orders.organization_id" => organization.id).
      flat_map { |subscription| subscription.platform }
  end
end
