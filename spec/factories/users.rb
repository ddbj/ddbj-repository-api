FactoryBot.define do
  factory :user do
    sequence(:uid) { "user#{_1}" }

    sub { SecureRandom.uuid }
  end
end
