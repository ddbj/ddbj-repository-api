FactoryBot.define do
  factory :dway_user do
    sequence(:uid) { "user#{_1}" }

    sub { SecureRandom.uuid }
  end
end
