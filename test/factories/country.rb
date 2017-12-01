FactoryGirl.define do
  factory :country do
    sequence(:name) { |n| "#{Faker::Address.country}-#{n}" }
    sequence(:code) { |n| "#{Faker::Code.ean}-#{n}" }
    region "North America"
  end
end
