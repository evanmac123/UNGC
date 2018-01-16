FactoryGirl.define do
  factory :role do
    name Faker::Name.name
    description Faker::Lorem.sentence

    trait :integrity_team_member do
      name Role::FILTERS[:integrity_team_member]
    end

    trait :integrity_manager do
      name Role::FILTERS[:integrity_manager]
    end

    trait :network_executive_director do
      name Role::FILTERS[:network_executive_director]
    end

    trait :network_board_chair do
      name Role::FILTERS[:network_board_chair]
    end

    trait :contact_point do
      name Role::FILTERS[:contact_point]
    end

    trait :network_focal_point do
      name Role::FILTERS[:network_focal_point]
    end

    trait :action_platform_manager do
      name Role::FILTERS[:action_platform_manager]
    end

    trait :website_editor do
      name Role::FILTERS[:website_editor]
    end
  end
end
