FactoryBot.define do
  factory :resource_link do
    title { Faker::Lorem.sentence }
    link_type :doc
  end
end
