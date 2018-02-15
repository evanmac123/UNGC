FactoryBot.define do
  factory :event do
    title { Faker::Name.title }
    description { Faker::Lorem.sentence }
    thumbnail_image_file_name { 'thumbnail.jpg' }
    thumbnail_image_content_type { 'image/jpeg' }
    thumbnail_image_file_size { 1024 }

    banner_image_file_name { 'banner.jpg' }
    banner_image_content_type { 'image/jpeg' }
    banner_image_file_size { 1024 }
  end
end
