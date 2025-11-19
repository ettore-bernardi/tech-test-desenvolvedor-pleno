FactoryBot.define do
  factory :processing_log do
    status { %w[pending processing success error].sample }
    error_message { Faker::Lorem.sentence }
    extracted_data_json { { name: Faker::Name.name, email: Faker::Internet.email } }
  end
end
