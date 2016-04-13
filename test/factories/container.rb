FactoryGirl.define do
  factory :container do
    layout :home
    path { Faker::Internet.url("").gsub('http://', '') }
    slug { Faker::Internet.slug }
  end
end
