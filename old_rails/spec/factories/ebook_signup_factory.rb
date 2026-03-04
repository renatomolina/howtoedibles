FactoryBot.define do
  factory :ebook_signup do
    email { Faker::Internet.email }
  end
end
