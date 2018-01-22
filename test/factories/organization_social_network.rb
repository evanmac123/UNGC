FactoryBot.define do
  factory :organization_social_network do
    association :organization
    network_code 'twitter'

    handle { Faker::Twitter.screen_name }
  end
end
