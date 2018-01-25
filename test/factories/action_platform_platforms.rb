FactoryGirl.define do
  factory :action_platform_platform, class: ActionPlatform::Platform do
    name { Faker::Hipster.words(2).map(&:titlecase).join(" ") }
    description { Faker::Hipster.sentence }
    slug { Faker::Hipster.word.downcase }

    default_starts_at Date.current.beginning_of_year
    default_ends_at Date.current.end_of_year

    trait :with_subscriptions do
      after(:build) do |platform|
        platform.subscriptions << create(:action_platform_subscription)
      end
    end
  end
end
