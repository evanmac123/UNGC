FactoryBot.define do
  factory :cop_link do
    language
    url { Faker::Internet.url }
    attachment_type 'cop'
  end
end
