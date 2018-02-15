FactoryBot.define do
  factory :communication_on_progress do
    organization
    title { Faker::Name.title }
  end
end
