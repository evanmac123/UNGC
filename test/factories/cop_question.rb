FactoryBot.define do
  factory :cop_question do
    text { Faker::Lorem.sentence }
    grouping { Faker::Lorem.word }
  end
end
