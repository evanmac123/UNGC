FactoryGirl.define do
  factory :contact do
    prefix { Faker::Name.prefix }
    first_name { Faker::Name.first_name }
    email { Faker::Internet.email }
    last_name { Faker::Name.last_name }
    job_title { Faker::Name.title }
    address { Faker::Address.street_address }
    city { Faker::Address.city }
    country
    phone { Faker::PhoneNumber.phone_number }
    sequence(:username) do |n|
      Faker::Internet.user_name + n.to_s
    end
    password { Faker::Internet.password }
  end
end
