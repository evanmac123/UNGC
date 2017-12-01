FactoryGirl.define do
  factory :action_platform_platform, class: 'ActionPlatform::Platform' do
    name { Faker::Hipster.words(2).map(&:titlecase).join(" ") }
    description { Faker::Hipster.sentence }
    slug { Faker::Hipster.word.downcase }
  end

  factory :action_platform, class: 'ActionPlatform::Platform' do
    name { Faker::Hipster.words(2).map(&:titlecase).join(" ") }
    description { Faker::Hipster.sentence }
    slug { Faker::Hipster.word.downcase }
  end
end
