# == Schema Information
#
# Table name: action_platform_platforms
#
#  id           :integer          not null, primary key
#  name         :string(255)      not null
#  description  :string(5000)     not null
#  default_starts_on   :datetime  not null
#  default_ends_on     :datetime  not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  slug         :string(32)       not null
#  discontinued :boolean          default(FALSE), not null
#

class ActionPlatform::Platform < ActiveRecord::Base
  has_many :subscriptions, dependent: :restrict_with_error

  validates :name, presence: true, length: { maximum: 255 }
  validates :description, presence: true, length: { maximum: 5_000 }
  validates :slug, presence: true, length: { maximum: 32 }
  validate :end_date_after_start_date?

  scope :available_for_signup, -> { where(discontinued: false) }

  after_commit Crm::ActionPlatformSyncJob::CommitHook.new(:create), on: :create
  after_commit Crm::ActionPlatformSyncJob::CommitHook.new(:update), on: :update
  after_commit Crm::ActionPlatformSyncJob::CommitHook.new(:destroy), on: :destroy

  def self.with_subscription_counts
    joins('LEFT OUTER JOIN action_platform_subscriptions on platform_id = action_platform_platforms.id')
        .group(:id)
        .select('action_platform_platforms.*',
                "coalesce(sum(cast(" \
                    "(action_platform_subscriptions.state = 'approved'" \
                    "   AND starts_on <= CURRENT_DATE" \
                    "   AND expires_on >= CURRENT_DATE)" \
                " as DECIMAL)), 0) as active_subs",
                "coalesce(sum(cast(" \
                    "action_platform_subscriptions.state IN ('pending', 'ce_engagement_review')" \
                " as DECIMAL)), 0) as pending_subs",
                'count(*) as all_subs')
  end

  def all_subs
    # This will only return a value when using ActionPlatform::Platform.with_subscription_counts
    attributes['all_subs']
  end

  def active_subs
    # This will only return a value when using ActionPlatform::Platform.with_subscription_counts
    attributes['active_subs']
  end

  def end_date_after_start_date?
    return if default_starts_at.blank? && default_ends_at.blank?

    errors.add :default_ends_at, "must be after Platform subscription year default starts at" \
        if (default_ends_at || default_starts_at) <= (default_starts_at || default_ends_at)
  end

end
