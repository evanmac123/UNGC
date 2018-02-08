FactoryGirl.define do
  factory :crm_owner, class: Crm::Owner do
    contact
    sequence(:crm_id) { |n| "005A0#{n.to_s.rjust(10, '0')}MVK" }
  end
end
