class ActionPlatform::Order < ActiveRecord::Base
  has_many :subscriptions, dependent: :destroy
  belongs_to :organization
  belongs_to :financial_contact, class_name: "Contact"

  validates :organization, presence: true
  validates :financial_contact, presence: true

  after_initialize do
    self.status ||= "pending"
  end

  enum status: {
    "pending": 0
  }
end
