# == Schema Information
#
# Table name: donations
#
#  id               :integer          not null, primary key
#  amount_cents     :integer          default(0), not null
#  amount_currency  :string(255)      default("USD"), not null
#  first_name       :string(255)      not null
#  last_name        :string(255)      not null
#  company_name     :string(255)      not null
#  address          :string(255)      not null
#  address_more     :string(255)
#  city             :string(255)      not null
#  state            :string(255)      not null
#  postal_code      :string(255)      not null
#  country_name     :string(255)      not null
#  email_address    :string(255)      not null
#  contact_id       :integer
#  organization_id  :integer
#  reference        :string(255)      not null
#  response_id      :string(255)
#  full_response    :text
#  status           :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  invoice_number   :string(255)
#  credit_card_type :string(255)
#

class Donation < ActiveRecord::Base
  include SalesforceRecordConcern

  enum status: {
    pending: 0,
    succeeded: 1,
    failed: 2,
  }

  belongs_to :contact
  belongs_to :organization

  monetize :amount_cents

  after_initialize do
    self.reference = SecureRandom.hex(10)
  end

  before_save do
    self.company_name ||= organization.try!(:name)
  end

  before_validation do
    if organization_id.blank? && company_name.present?
      self.organization = Organization.find_by(name: company_name)
    end
  end

  validates :amount, presence: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :address, presence: true
  validates :city, presence: true
  validates :state, presence: true
  validates :postal_code, presence: true
  validates :country_name, presence: true
  validates :email_address, presence: true
  validates :reference, presence: true
  validates :organization, presence: true

  def metadata
    {
      reference: reference,
      contact_id: contact_id,
      contact_name: contact.try!(:name),
      organization_id: organization_id,
      organization_name: contact.try!(:organization).try!(:name),
      invoice_number: invoice_number,
      invoice_code: invoice_code,
      credit_card_type: credit_card_type
    }
  end

  # invoice_number with the organization_id portion removed
  def invoice_code
    _id, code = split_invoice_code_and_organization_id
    code
  end

  private

  def split_invoice_code_and_organization_id
    return [] if invoice_number.blank?

    invoice_number.split(/\W+/).
      select{|s| s.length >= 1}.
      take(2)
  end
end
