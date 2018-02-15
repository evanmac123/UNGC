FactoryBot.define do
  factory :logo_comment do
    contact
    logo_request
    body { Faker::Lorem.paragraph }
    attachment_file_name { Faker::Lorem.word }
    attachment_content_type 'application/pdf'
    attachment_file_size 1024
  end
end
