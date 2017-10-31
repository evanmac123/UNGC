FactoryGirl.define do
  factory :action_platform_platform, class: 'ActionPlatform::Platform' do
    name { Faker::Hipster.words(2).map(&:titlecase).join(" ") }
    description { Faker::Hipster.sentence }
    slug { Faker::Hipster.word.downcase }
    discontinued false 
  end
end
