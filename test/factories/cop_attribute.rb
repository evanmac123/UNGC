FactoryGirl.define do
  factory :cop_attribute do
    cop_question
    hint { Faker::Lorem.sentence }
  end
end
