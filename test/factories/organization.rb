FactoryGirl.define do
  factory :organization do
    organization_type
    country
    name { Faker::Company.name }
    employees { Faker::Number.number(4) }
    pledge_amount { Faker::Number.number(4) }
    url { Faker::Internet.url }

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

    trait :inactive do
      active false
    end

    factory :delisted_participant do
      inactive
      participant true
      delisted_on Date.today
      inactive_on Date.today
      cop_state Organization::COP_STATE_DELISTED
      removal_reason { RemovalReason.for_filter(:delisted).first }
    end

    factory :business do
      active_participant
      employees 11 # just big enough to be an SME
    end

    factory :non_business do
      active_participant

      after(:build) do |org|
        org.organization_type = OrganizationType.academic
      end
    end

  end
end
