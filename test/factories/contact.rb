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

    factory :staff_contact do
      organization { Organization.find_by!(name: DEFAULTS[:ungc_organization_name]) }

      trait :integrity_team_member do
        after(:build) do |contact, evaluator|
          contact.roles << Role.integrity_team_member
        end
      end

      trait :integrity_manager do
        after(:build) do |contact, evaluator|
          contact.roles << Role.integrity_manager
        end
      end
    end
  end
end
