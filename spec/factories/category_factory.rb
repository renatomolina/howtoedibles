FactoryBot.define do
  factory :category do
    name { Faker::Lorem.word }
    slug { Faker::Lorem.word }
  end
end
