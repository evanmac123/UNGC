FactoryBot.define do
  factory :sdg_pioneer_other, :class => SdgPioneer::Other do
    organization_name Faker::Company.name
    is_participant Faker::Boolean.boolean
    submitter_name { Faker::Name.name }
    submitter_place_of_work { Faker::Company.name }
    submitter_job_title { Faker::Name.title }
    submitter_email { Faker::Internet.email }
    submitter_phone { Faker::PhoneNumber.phone_number }
    sdg_pioneer_role :change_makers
    nominee_name { Faker::Name.name }
    nominee_work_place { Faker::Company.name }
    nominee_title { Faker::Name.title }
    nominee_email { Faker::Internet.email }
    nominee_phone { Faker::PhoneNumber.phone_number }
    why_nominate { Faker::Lorem.sentence }
    organization_name_matched Faker::Boolean.boolean
    accepts_tou true
  end
end
