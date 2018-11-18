FactoryBot.define do
  factory :resource_weight do
    resource nil
    resource_title { Faker::Lorem.sentence }
    resource_url { Faker::Internet.url }
    resource_type { 'pdf' }
    full_text "MyText"
    full_text_raw "MyText"
    weights { "" }
  end
end
