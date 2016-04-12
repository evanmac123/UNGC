FactoryGirl.define do
  factory :logo_request do
    organization
    publication { create(:logo_publication) }
    purpose { Faker::Lorem.paragraph[0,255] }
  end
end
