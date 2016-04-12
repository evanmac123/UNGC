FactoryGirl.define do
  factory :cop_answer do
    communication_on_progress
    cop_attribute
    text { Faker::Lorem.sentence }
  end
end
