# == Schema Information
#
# Table name: action_platform_platforms
#
#  id           :integer          not null, primary key
#  name         :string(255)      not null
#  description  :string(5000)      not null
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

  scope :available_for_signup, -> { where(discontinued: false) }

  after_commit Crm::CommitHooks.new(:create), on: :create
  after_commit Crm::CommitHooks.new(:update), on: :update
  after_commit Crm::CommitHooks.new(:destroy), on: :destroy

  def self.with_subscription_counts
    joins('LEFT OUTER JOIN action_platform_subscriptions on platform_id = action_platform_platforms.id')
        .group(:id)
        .select('action_platform_platforms.*',
                "cast(expires_on >= current_timestamp as unsigned integer) as active_subs",
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
end
