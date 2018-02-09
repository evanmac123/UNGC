FactoryGirl.define do
  factory :organization do
    organization_type
    country
    sequence(:name) { |n| "#{Faker::Company.name}-#{n}" }
    employees { Faker::Number.number(4) }
    pledge_amount { Faker::Number.number(4) }
    url { Faker::Internet.url }
    government_registry_url { Faker::Internet.url }

    # HACK
    # Builds a valid, approved, active, participant business organization
    # working around the callbacks in organization and
    # ensuring the appropriate OrganizationTypes are created.
    #
    # This is a common source of confusion and should be refactored
    # away. Ideally we'd move the organization_type calculations outside
    # of the model and refactor OrganizationType into an enum so all of
    # this setup wouldn't be neccessary.

    # represents an active participant
    trait :active_participant do
      state 'approved'
      participant true
      active true
    end

    trait :with_record_id do
      sequence(:record_id) { |n| "00D0D#{n.to_s.rjust(10, '0')}MVK" }
    end

    factory :crm_organization, traits: [:with_record_id, :with_sector]

    trait :participant_level do
      level_of_participation Organization.level_of_participations[:participant_level]
    end

    trait :inactive do
      active false
    end

    factory :delisted_participant do
      inactive
      participant true
      delisted_on Date.current
      inactive_on Date.current
      cop_state Organization::COP_STATE_DELISTED
      removal_reason { RemovalReason.for_filter(:delisted).first }
    end

    factory :business do
      active_participant
      employees 11 # just big enough to be an SME
    end

    trait :with_sector do
      sector { build(:sector) }
    end

    factory :non_business do
      active_participant

      after(:build) do |org|
        org.organization_type = OrganizationType.academic
      end
    end

    trait :has_participant_manager do
      association :participant_manager, factory: :contact
    end

    factory :organization_with_participant_manager, traits: [:has_participant_manager]

    trait :with_contact do
      after(:build) do |org|
        create(:contact_point, organization: org)
      end
    end
  end
end
