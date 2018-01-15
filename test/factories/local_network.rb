FactoryGirl.define do
  factory :local_network do
    name { Faker::Name.name  }

    trait :with_network_contact do
      after(:build) do |local_network, evaluator|
        local_network.contacts << create(:staff_contact, :network_focal_point)
      end
    end
  end
end
