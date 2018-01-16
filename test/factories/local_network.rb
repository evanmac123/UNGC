FactoryGirl.define do
  factory :local_network do
    name { Faker::Name.name  }

    trait :with_network_contact do
      after(:build) do |local_network, evaluator|
        local_network.contacts << create(:staff_contact, :network_focal_point)
      end
    end

    trait :with_executive_director do
      after(:build) do |local_network, evaluator|
        local_network.contacts << create(:contact, :network_executive_director)
      end
    end

    trait :with_board_chair do
      after(:build) do |local_network, evaluator|
        local_network.contacts << create(:contact, :network_board_chair)
      end
    end

    trait :with_report_recipient do
      after(:build) do |local_network, evaluator|
        local_network.contacts << create(:contact, :network_report_recipient)
      end
    end
  end
end
