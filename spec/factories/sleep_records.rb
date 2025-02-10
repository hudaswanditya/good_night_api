FactoryBot.define do
  factory :sleep_record do
    association :user
    clock_in { Faker::Time.backward(days: 7, period: :evening) }
    clock_out { clock_in + rand(1..8).hours }
  end
end
