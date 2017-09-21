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
#  full_response    :text(65535)
#  status           :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  invoice_number   :string(255)
#  credit_card_type :string(255)
#

class Donation::Form < Donation
  attr_accessor :name_on_card, :token

  validates :token, presence: true
  validate :minimum_amount

  def self.from(contact:)
    params = {
      first_name: contact.first_name,
      last_name: contact.last_name,
      address: contact.address,
      address_more: contact.address_more,
      city: contact.city,
      state: contact.state,
      postal_code: contact.postal_code,
      country_name: contact.country_name,
      email_address: contact.email,
      contact_id: contact.id,
      name_on_card: contact.name,
    }

    if contact.from_organization?
      params[:company_name] = contact.organization.name
      params[:amount] =  contact.organization.suggested_pledge
      params[:organization_id] ||= contact.organization_id
    end

    new(params)
  end

  def publishable_key
    key = Rails.application.secrets.stripe.try(:[], "publishable_key")
    if key.present?
      key
    else
      raise <<-MESSAGE

      ***************************************************
      Stripe API Keys are missing from config/secrets.yml
      ***************************************************

      You need to add:
      stripe:
        publishable_key: pk_test_.....
        secret_key: sk_test_.....

      to config/secrets.yml under the 'development' and 'test' sections
      See config/secrets.yml.example

      MESSAGE
    end
  end

  def contact_id
    id = super
    return id if id.present? || organization.nil?

    # contact_id is nil and we have an organization
    # try to match one of the contacts
    self.contact_id = organization.contacts.where(
      "email = ? or (first_name = ? and last_name = ?)", email_address,
      first_name, last_name).first.try!(:id)
  end

  def formatted_amount
    if amount > 0
      amount.format
    end
  end

  def minimum_amount
    if amount.fractional < 50
      errors.add(:amount, "must be at least 50 cents")
    end
  end

  def credit_card_types
    [
      "Visa",
      "Mastercard",
      "Amex",
      "Discover",
      "Diners Club",
    ]
  end

end
