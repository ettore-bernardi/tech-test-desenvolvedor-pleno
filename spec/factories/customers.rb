FactoryBot.define do
  factory :customer do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    phone { Faker::PhoneNumber.phone_number }
    product_code { Faker::Alphanumeric.alphanumeric(number: 10) }
  end
end
