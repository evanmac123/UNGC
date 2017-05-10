# == Schema Information
#
# Table name: action_platform_orders
#
#  id                   :integer          not null, primary key
#  organization_id      :integer          not null
#  financial_contact_id :integer          not null
#  status               :integer          default(0), not null
#  price_cents          :integer          default(0), not null
#  price_currency       :string(255)      default("USD"), not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

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
    "pending" => 0
  }
end
