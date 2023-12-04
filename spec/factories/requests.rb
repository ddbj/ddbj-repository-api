FactoryBot.define do
  factory :request do
    after :create do |request|
      create :obj, request:, _id: '_base'
    end
  end
end
