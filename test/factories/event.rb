FactoryGirl.define do
  factory :event do
    title { Faker::Name.title }
    description { Faker::Lorem.sentence }
    thumbnail_image { Faker::Avatar.image("my-own-slug", "50x50", "jpg") }
    banner_image { Faker::Avatar.image("my-own-slug", "50x50", "jpg") }
  end
end
