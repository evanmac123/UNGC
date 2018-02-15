FactoryBot.define do
  factory :salesforce_record, class: SalesforceRecord do
    sequence(:record_id) { |n| "00D0D#{n.to_s.rjust(10, '0')}MVK" }
  end
end
