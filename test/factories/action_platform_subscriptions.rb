FactoryGirl.define do
  factory :action_platform_subscription, class: 'ActionPlatform::Subscription' do
    contact {association :contact_point, organization: organization }
    association :organization, :has_participant_manager
    association :platform, factory: :action_platform_platform
    association :order, factory: :action_platform_order
    starts_on Date.current.beginning_of_year
    expires_on Date.current.end_of_year

    trait :approved do
      state :approved
    end
  end
end
