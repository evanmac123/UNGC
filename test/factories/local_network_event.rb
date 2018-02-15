FactoryBot.define do
  factory :local_network_event do
    title { Faker::Lorem.sentence }
    description { Faker::Lorem.paragraph }
    event_type { Faker::Lorem.word }
    date { Faker::Date.forward(20) }
    num_participants { Faker::Number.number(3) }
    gc_participant_percentage { Faker::Number.number(2) }
    after(:build) do |o|
      o.attachments.build
    end
    local_network {
      build(:local_network, countries: [build(:country)])
    }
  end
end
