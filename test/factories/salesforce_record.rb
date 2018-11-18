FactoryBot.define do
  factory :salesforce_record, class: SalesforceRecord do
    sequence(:record_id) do |n|
      salesforce_rnd = rand(10**9..10**10)
      "00D0D#{salesforce_rnd}MVK"
    end
  end
end
