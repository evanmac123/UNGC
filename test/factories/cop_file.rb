FactoryBot.define do
  factory :cop_file do
    language
    attachment_file_name { Faker::Lorem.word }
    attachment_content_type 'application/pdf'
    attachment_file_size 1024
    attachment_type 'cop'
  end
end
