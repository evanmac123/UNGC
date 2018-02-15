FactoryBot.define do
  factory :donation_form, class: Donation::Form do
    amount "$0.50"
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    address { Faker::Address.street_address }
    address_more { Faker::Address.secondary_address }
    city { Faker::Address.city }
    state { Faker::Address.state }
    postal_code { Faker::Address.postcode }
    email_address { Faker::Internet.email }
    country_name { build(:country).name }
    reference { SecureRandom.hex(12) }
    token "abc123"
    contact
    organization
    status "succeeded"

    trait :with_invoice do
      invoice_number { "#{organization.id}-"+Faker::Number.number(10) }
    end

  end
end
