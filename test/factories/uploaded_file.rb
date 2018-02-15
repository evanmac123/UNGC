FactoryBot.define do
  factory :uploaded_file do
    attachment_file_name { Faker::Lorem.word }
    attachment_content_type { 'application/pdf' }
    attachment_file_size { 1024 }
  end
end
