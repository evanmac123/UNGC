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

  after_commit Crm::CommitHooks.new(:create), on: :create
  after_commit Crm::CommitHooks.new(:update), on: :update
  after_commit Crm::CommitHooks.new(:destroy), on: :destroy

  ACTIVE_STATES = %w[approved].freeze
  ALL_STATES = [:pending, :ce_engagement_review, :declined, :approved]

  scope :active_at, -> (on_date=Date.current) {
    # "expires_on between '2018-01-01' and '2028-01-01'" -- far future end date allows efficent BETWEEN
    where(state: :approved, expires_on: on_date.strftime('%F')..(on_date + 10.years).strftime('%F'))
  }
  scope :related_to_contact, -> (contact, only_mine=false) {
    return where(contact: contact) if only_mine

    includes(:organization)
        .joins('LEFT OUTER JOIN organizations ON organizations.id = action_platform_subscriptions.organization_id')
        .where('(action_platform_subscriptions.contact_id = :contact_id ' \
                'OR organizations.participant_manager_id = :contact_id)', contact_id: contact.id)
  }

  validate :contact_is_from_organization

  def self.for_state(state)
    query = where(state: state)
    state == 'approved' ? query.active_at : query
  end

  state_machine initial: :pending do
    state :ce_engagement_review
    state :declined
    state :approved do
      validates_presence_of :starts_on, :expires_on
      validate :date_range_valid?
    end

    event :approve do
      transition [:pending, :ce_engagement_review] => :approved
    end

    event :decline do
      transition [:pending, :ce_engagement_review] => :declined
    end

    event :back_to_pending do
      transition [:approved, :ce_engagement_review, :declined] => :pending
    end

    event :send_to_ce_review do
      transition [:pending] => :ce_engagement_review
    end
  end

  def approve!(approver)
    super
  end

  def decline!(approver)
    super
   end

  def back_to_pending!(actor)
    super
  end

  def send_to_ce_review!(actor)
    super
  end

  def active?
    approved? && (expires_on >= Date.current)
  end

  def expired?
    Date.current > expires_on
  end

  def in_review?
    %w[pending ce_engagement_review].include?(state)
  end

  def self.has_active_subscription?(contact)
    active_at.related_to_contact(contact, true).exists?
  end

  def self.for(organization:)
    joins(:order, :platform)
        .includes(:order, :platform)
        .where(action_platform_orders: { organization_id: organization })
        .flat_map { |subscription| subscription.platform }
  end

  def date_range_valid?
    return if starts_on.blank? && expires_on.blank?

    errors.add :expires_on, "must be after subscription start date" and return if (expires_on || starts_on) <= (starts_on || expires_on)

    overlapping_approved = ActionPlatform::Subscription
                               .where(platform_id: self.platform_id,
                                      organization_id: self.organization_id,
                                      state: :approved)
                               .where('starts_on BETWEEN :starts AND :expires OR expires_on BETWEEN :starts AND :expires',
                                      starts: self.starts_on.strftime('%F'),
                                      expires: self.expires_on.strftime('%F'))

    overlapping_approved = overlapping_approved.where.not(id: self.id) if persisted?

    errors.add :base, "Only one approved subscription can be active at once" if overlapping_approved.exists?
  end

  def contact_is_from_organization
    errors.add :base, "Contact's organization is not the same as the Subscription's organization" \
      unless self.contact&.organization_id == self.organization_id
  end
end
