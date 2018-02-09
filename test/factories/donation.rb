FactoryGirl.define do
  factory :donation do
    amount { "$#{Faker::Number.decimal(3, 2)}" }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    company_name { Faker::Company.name }
    address { Faker::Address.street_address }
    address_more { Faker::Address.secondary_address }
    city { Faker::Address.city }
    state { Faker::Address.state }
    postal_code { Faker::Address.postcode }
    email_address { Faker::Internet.email }
    country_name { build(:country).name }
    reference { SecureRandom.hex(12) }
    contact
    organization
    status "succeeded"

    full_response JSON.generate({response: "Hi"})

    trait :with_record_id do
      sequence(:record_id) { |n| "8050D#{n.to_s.rjust(10, '0')}MVK" }
    end
  end
end
