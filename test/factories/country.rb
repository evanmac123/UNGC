FactoryGirl.define do
  factory :country do
    name Faker::Address.country
    region "North America"
    code Faker::Code.ean
  end
end
