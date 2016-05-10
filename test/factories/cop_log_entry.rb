FactoryGirl.define do
  factory :cop_log_entry do
    event :test_event
    cop_type :cop
    status :ok
    contact
    organization
  end
end
