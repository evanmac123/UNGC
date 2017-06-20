FactoryGirl.define do
  factory :crm_owner, class: 'Crm::Owner' do
    contact
    crm_id "ABCD1234"
  end
end
