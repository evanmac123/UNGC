FactoryGirl.define do
  factory :comment do
    body { Faker::Lorem.paragraph }
    commentable factory: :organization
    contact
  end
end
