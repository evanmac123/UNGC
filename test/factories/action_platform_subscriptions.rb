FactoryGirl.define do
  factory :action_platform_subscription, class: 'ActionPlatform::Subscription' do
    contact
    organization
    association :platform, factory: :action_platform_platform
    association :order, factory: :action_platform_order
    expires_on { 1.week.from_now }

    trait :approved do
      status :approved
    end
  end
end
