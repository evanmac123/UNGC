FactoryGirl.define do
  factory :logo_file do
    name { Faker::Name.name }
    thumbnail { Faker::Avatar.image("my-own-slug", "50x50", "jpg") }
  end
end
