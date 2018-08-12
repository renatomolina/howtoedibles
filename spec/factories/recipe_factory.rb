FactoryBot.define do
  factory :recipe do
    name { Faker::Food.dish }
    ingredients { Faker::Lorem.paragraphs }
    instructions { Faker::Lorem.paragraphs }
    description { Faker::Lorem.sentence }
  end
end
