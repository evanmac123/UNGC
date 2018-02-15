FactoryBot.define do
  factory :exchange do
    name { Faker::Company.name }
    code { Faker::Internet.password(3,3) }
  end
end
