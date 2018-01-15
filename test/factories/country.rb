FactoryGirl.define do
  factory :country do
    sequence(:name) { |n| "#{Faker::Address.country}-#{n}" }
    sequence(:code) { |n| "#{Faker::Code.ean}-#{n}" }
    region "North America"

    trait :with_local_network do
      association :local_network, :with_network_contact
    end
  end
end
