FactoryBot.define do
  factory :recipe do
    name { Faker::Food.dish }
    slug { Faker::Lorem.word }
    ingredients { Faker::Lorem.paragraphs }
    instructions { Faker::Lorem.paragraphs }
    description { Faker::Lorem.sentence }
    photo_file_name { 'photo.jpg' }
    photo_content_type { 'image/jpg' }
    photo_file_size { 1024 }
    category
  end
end
