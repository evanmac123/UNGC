FactoryGirl.define do
  factory :action_platform_subscription, class: 'ActionPlatform::Subscription' do
    association :organization, :has_participant_manager
    contact {association :contact_point, organization: organization }
    association :platform, factory: :action_platform_platform
    association :order, factory: :action_platform_order
    starts_on Date.current.beginning_of_year
    expires_on Date.current.end_of_year

    trait :approved do
      state :approved
    end

    trait :with_record_id do
      sequence(:record_id) { |n| "00x0D#{n.to_s.rjust(10, '0')}MVK" }
    end

    factory :crm_action_platform_subscription, traits: [:with_record_id]
  end
end
