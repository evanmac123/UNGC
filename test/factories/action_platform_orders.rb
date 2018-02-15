FactoryBot.define do
  factory :action_platform_order, class: 'ActionPlatform::Order' do
    organization
    association :financial_contact, factory: :contact
    price_cents 2000
  end
end
