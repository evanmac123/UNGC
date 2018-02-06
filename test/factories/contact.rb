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
    password {
      [
        'a',                             # at least 1 lower case letter
        'B',                             # at least 1 upper case letter
        Faker::Number.number(1),         # 1 digit
        Faker::Internet.password(3, 125) # randomness
      ].join
    }
    last_password_changed_at { Contact::STRONG_PASSWORD_POLICY_DATE }

    factory :contact_point do
      organization

      after(:build) do |contact, evaluator|
        contact.roles << (Role.contact_point || create(:role, :contact_point))
      end
    end

    factory :staff_contact do
      organization { Organization.find_by!(name: DEFAULTS[:ungc_organization_name]) }

      trait :integrity_team_member do
        after(:build) do |contact, evaluator|
          contact.roles << (Role.integrity_team_member || create(:role, :integrity_team_member))
        end
      end

      trait :integrity_manager do
        after(:build) do |contact, evaluator|
          contact.roles << (Role.integrity_manager || create(:role, :integrity_manager))
        end
      end

      trait :action_platform_manager do
        after(:build) do |contact, evaluator|
          contact.roles << (Role.action_platform_manager || create(:role, :action_platform_manager))
        end
      end

      trait :website_editor do
        after(:build) do |contact, evaluator|
          contact.roles << (Role.website_editor || create(:role, :website_editor))
        end
      end
    end

    factory :ceo_contact do
      after(:build) do |contact, evaluator|
        contact.roles << (Role.ceo || create(:role, :ceo))
      end
    end

    trait :financial_contact do
      after(:build) do |contact, evaluator|
        contact.roles << (Role.financial_contact || create(:role, :financial_contact))
      end
    end

    trait :participant_manager do
      after(:build) do |contact, evaluator|
        contact.roles << (Role.participant_manager || create(:role, :participant_manager))
      end
    end

    trait :network_focal_point do
      after(:build) do |contact, evaluator|
        contact.roles << (Role.network_focal_point || create(:role, :network_focal_point))
      end
    end

    trait :network_report_recipient do
      after(:build) do |contact, evaluator|
        # Role needs to be created here to avoid a race condition in the tests
        Role.network_executive_director || create(:role, :network_executive_director)
        contact.roles << (Role.network_report_recipient || create(:role, :network_report_recipient))
      end
    end

    trait :network_executive_director do
      after(:build) do |contact, evaluator|
        contact.roles << (Role.network_executive_director || create(:role, :network_executive_director))
      end
    end

    trait :network_board_chair do
      after(:build) do |contact, evaluator|
        contact.roles << (Role.network_board_chair || create(:role, :network_board_chair))
      end
    end

    trait :network_guest_user do
      after(:build) do |contact, evaluator|
        contact.roles << (Role.network_guest_user || create(:role, :network_guest_user))
      end
    end
  end
end
